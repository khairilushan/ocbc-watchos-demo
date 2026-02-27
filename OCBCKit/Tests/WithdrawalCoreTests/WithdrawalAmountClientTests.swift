import Foundation
import Testing
@testable import Networking
@testable import WithdrawalCore

@Test
func fetchConfiguration_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/parameter/withdrawal-amount")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:50:57 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let config = try await client.fetchAmountConfiguration(.otp)
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/parameter/withdrawal-amount")
    #expect(request.value(forHTTPHeaderField: "URI") == "/parameter/withdrawal-amount")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(String(data: request.httpBody ?? Data(), encoding: .utf8) == "{\"withdrawalType\":\"OTP\"}")

    #expect(config.minimumAmount == 100000)
    #expect(config.maximumAmount == 2500000)
    #expect(config.denominationAmount == 100000)
    #expect(config.parameters.count == 2)
    #expect(config.parameters[0] == .init(code: "100000", value: "IDR 100,000"))
    #expect(config.parameters[1] == .init(code: "200000", value: "IDR 200,000"))
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
  "response_code": "00000",
  "responseDescription": "SUCCESS",
  "responseTitle": "",
  "language": "EN",
  "data": {
    "parameters": [
      {
        "code": "100000",
        "value": "IDR 100,000"
      },
      {
        "code": "200000",
        "value": "IDR 200,000"
      }
    ],
    "minimumAmount": 100000,
    "maximumAmount": 2500000,
    "denominationAmount": 100000
  }
}
"""
