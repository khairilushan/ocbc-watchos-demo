import Foundation
import Testing
@testable import Networking
@testable import WithdrawalCore

@Test
func fetchAccounts_requestsEndpointAndMapsResponse() async throws {
    let recorder = RequestRecorder2()
    let data = sampleSourceOfFundsResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/source-of-funds")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient2(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture2,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator2(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider2(value: "Fri Feb 27 14:50:38 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider2(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider2(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner2(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let accounts = try await client.fetchSourceOfFunds()
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "GET")
    #expect(request.url?.absoluteString == "https://example.com/card/withdrawal/source-of-funds")
    #expect(request.value(forHTTPHeaderField: "URI") == "/card/withdrawal/source-of-funds")

    #expect(accounts.count == 2)
    #expect(accounts[0].productCode == "TBSMCY9902")
    #expect(accounts[0].accountNo == "693810029464")
    #expect(accounts[0].accountCcy == "IDR")
    #expect(accounts[0].balance == 999558224.26)
    #expect(accounts[0].isAvailable == true)
}

private actor RequestRecorder2 {
    private var request: URLRequest?

    func set(request: URLRequest) {
        self.request = request
    }

    func latestRequest() -> URLRequest? {
        request
    }
}

private struct SpyHTTPClient2: HTTPClient {
    let recorder: RequestRecorder2
    let result: (Data, URLResponse)

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

private struct FixedNonceGenerator2: NonceGenerator {
    let value: String

    func makeNonce() -> String { value }
}

private struct FixedTimestampProvider2: TimestampProvider {
    let value: String

    func now() -> Date { .distantPast }

    func string(from date: Date) -> String { value }
}

private struct FixedSessionProvider2: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? { value }
}

private struct FixedAccessTokenProvider2: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? { value }
}

private struct FixedSigner2: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

private extension NetworkingConfig {
    static var fixture2: Self {
        .init(
            baseURL: URL(string: "https://example.com")!,
            apiKey: "apikey-123",
            userAgent: "iOS/4.4.4 (iOS)",
            acceptLanguage: "EN",
            omniChannel: "iOS",
            platform: "iOS",
            appVersion: "4.4.4"
        )
    }
}

private let sampleSourceOfFundsResponse = """
{
  "responseDescription": "SUKSES",
  "responseTitle": "",
  "language": "IN",
  "response_code": "00000",
  "data": {
    "accounts": [
      {
        "productCode": "TBSMCY9902",
        "productName": "Tanda360Plus-Digital",
        "accountNo": "693810029464",
        "accountType": "S",
        "accountCcy": "",
        "branchCode": "99693",
        "mcBit": "Y",
        "dynamicAccountId": "",
        "bankCode": "999",
        "bankName": "",
        "description": "",
        "qrCode": "",
        "accountBalances": [
          {
            "accountCcy": "IDR",
            "balance": 999558224.26,
            "holdBalance": 0,
            "isAvailable": true,
            "accountCcyNameID": "Rupiah Indonesia",
            "accountCcyNameEN": "Indonesian Rupiah"
          }
        ]
      },
      {
        "productCode": "GRRMCY9902",
        "productName": "GIRO BUSINESS SMART",
        "accountNo": "693800005375",
        "accountType": "D",
        "accountCcy": "",
        "branchCode": "99693",
        "mcBit": "Y",
        "dynamicAccountId": "",
        "bankCode": "999",
        "bankName": "",
        "description": "",
        "qrCode": "",
        "accountBalances": [
          {
            "accountCcy": "IDR",
            "balance": 45141301,
            "holdBalance": 0,
            "isAvailable": true,
            "accountCcyNameID": "Rupiah Indonesia",
            "accountCcyNameEN": "Indonesian Rupiah"
          }
        ]
      }
    ]
  }
}
"""
