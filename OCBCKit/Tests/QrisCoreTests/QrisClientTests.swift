import Foundation
import Testing
@testable import Networking
@testable import QrisCore

@Test
func fetchPrimaryAccount_decodesAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/qris/account/primary")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let client = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 10:38:57 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let qrisClient = QrisClient.live(apiClient: client)
    let account = try await qrisClient.fetchPrimaryAccount()
    let request = try #require(await recorder.latestRequest())

    #expect(request.url?.absoluteString == "https://example.com/qris/account/primary")
    #expect(request.value(forHTTPHeaderField: "URI") == "/qris/account/primary")
    #expect(account.qrCodePayload == "base64-qr-value")
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
    "isEligible": true,
    "account": {
      "productCode": "TBSMCY9901",
      "productName": "MasterCard Titanium",
      "accountNo": "",
      "cardNumber": "encrypted",
      "accountType": "C",
      "accountName": "AULIA RACHMAN",
      "accountCcy": "",
      "branchCode": "99693",
      "mcBit": "Y",
      "dynamicAccountId": "d6658cdc-0a92-4aaa-9474-04e833eb438a",
      "bankCode": "",
      "bankName": "",
      "description": "",
      "qrCode": "base64-qr-value",
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
    },
    "ownedCards": ["debitCard", "creditCard"],
    "tips": {
      "title": "",
      "description": "tip",
      "iconUrl": ""
    }
  },
  "response_code": "00000"
}
"""
