import Foundation
import Testing
@testable import Networking
@testable import WithdrawalCore

@Test
func verifyPinOTP_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder4()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/token/v3/verify/pin/otp")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient4(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture4,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator4(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider4(value: "Fri Feb 27 14:54:25 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider4(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider4(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner4(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let result = try await client.verifyPinOTP(
        .init(appliNumber: "1", otpCode: "123456", sequenceNumber: "0")
    )

    let request = try #require(await recorder.latestRequest())
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/token/v3/verify/pin/otp")
    #expect(request.value(forHTTPHeaderField: "URI") == "/token/v3/verify/pin/otp")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    let body = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
    #expect(body.contains("\"appliNumber\":\"1\""))
    #expect(body.contains("\"otpCode\":\"123456\""))
    #expect(body.contains("\"sequenceNumber\":\"0\""))

    #expect(result.responseCode == "00000")
    #expect(result.responseDescriptionEN == "SUCCESS")
    #expect(result.responseDescriptionID == "SUKSES")
}

private actor RequestRecorder4 {
    private var request: URLRequest?

    func set(request: URLRequest) {
        self.request = request
    }

    func latestRequest() -> URLRequest? {
        request
    }
}

private struct SpyHTTPClient4: HTTPClient {
    let recorder: RequestRecorder4
    let result: (Data, URLResponse)

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

private struct FixedNonceGenerator4: NonceGenerator {
    let value: String

    func makeNonce() -> String { value }
}

private struct FixedTimestampProvider4: TimestampProvider {
    let value: String

    func now() -> Date { .distantPast }

    func string(from date: Date) -> String { value }
}

private struct FixedSessionProvider4: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? { value }
}

private struct FixedAccessTokenProvider4: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? { value }
}

private struct FixedSigner4: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

private extension NetworkingConfig {
    static var fixture4: Self {
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
  "response_desc_en": "SUCCESS",
  "response_desc_id": "SUKSES"
}
"""
