import Foundation
import Testing
@testable import FundTransferCore
@testable import Networking

@Test
func fetchPrimaryAccount_requestsEndpointAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/fundtransfer/account/primary")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:50:22 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let client = FundTransferClient.live(apiClient: apiClient)
    let account = try await client.fetchPrimaryAccount()
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "GET")
    #expect(request.url?.absoluteString == "https://example.com/fundtransfer/account/primary")
    #expect(request.value(forHTTPHeaderField: "URI") == "/fundtransfer/account/primary")

    #expect(account.hasDefaultAccount == true)
    #expect(account.accountName == "AULIA RACHMAN")
    #expect(account.accountNo == "693810021529")
    #expect(account.accountCcy == "IDR")
    #expect(account.balance == 1586829543)
}

private actor RequestRecorder {
    private var request: URLRequest?

    func set(request: URLRequest) {
        self.request = request
    }

    func latestRequest() -> URLRequest? {
        request
    }
}

private struct SpyHTTPClient: HTTPClient {
    let recorder: RequestRecorder
    let result: (Data, URLResponse)

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

private struct FixedNonceGenerator: NonceGenerator {
    let value: String

    func makeNonce() -> String { value }
}

private struct FixedTimestampProvider: TimestampProvider {
    let value: String

    func now() -> Date { .distantPast }

    func string(from date: Date) -> String { value }
}

private struct FixedSessionProvider: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? { value }
}

private struct FixedAccessTokenProvider: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? { value }
}

private struct FixedSigner: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

private extension NetworkingConfig {
    static var fixture: Self {
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

private let sampleResponse = """
{
  "responseDescription": "SUKSES",
  "responseTitle": "",
  "language": "IN",
  "data": {
    "hasDefaultAccount": true,
    "account": {
      "productCode": "TBSMCY9901",
      "productName": "Tanda360Plus-S",
      "accountNo": "693810021529",
      "accountType": "S",
      "accountName": "AULIA RACHMAN",
      "accountCcy": "",
      "branchCode": "99693",
      "mcBit": "Y",
      "dynamicAccountId": "d6658cdc-0a92-4aaa-9474-04e833eb438a",
      "bankCode": "",
      "bankName": "",
      "description": "",
      "qrCode": "base64-qr",
      "accountBalances": [
        {
          "accountCcy": "IDR",
          "balance": 1586829543,
          "holdBalance": 0,
          "isAvailable": true,
          "accountCcyNameID": "",
          "accountCcyNameEN": ""
        }
      ]
    }
  },
  "response_code": "00000"
}
"""
