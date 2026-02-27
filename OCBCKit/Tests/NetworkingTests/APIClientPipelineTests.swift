import Foundation
import Testing
@testable import Networking

@Test
func execute_buildsRequest_headers_and_decodesResponse() async throws {
    let recorder = RequestRecorder()
    let endpoint = TestEndpoint()
    let responseData = #"{"value":"ok"}"#.data(using: .utf8)!
    let url = URL(string: "https://example.com")!
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (responseData, response))

    let client = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 07:15:22 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let result = try await client.execute(endpoint)
    let request = try #require(await recorder.latestRequest())

    #expect(result == .init(value: "ok"))
    #expect(request.httpMethod == "GET")
    #expect(request.url?.absoluteString == "https://example.com/qris/account/primary")
    #expect(request.value(forHTTPHeaderField: "User-Agent") == NetworkingConfig.fixture.userAgent)
    #expect(request.value(forHTTPHeaderField: "Accept-Language") == NetworkingConfig.fixture.acceptLanguage)
    #expect(request.value(forHTTPHeaderField: "X-OCBCNISP-OMNI-CHANNEL") == NetworkingConfig.fixture.omniChannel)
    #expect(request.value(forHTTPHeaderField: "X-OCBC-Platform") == NetworkingConfig.fixture.platform)
    #expect(request.value(forHTTPHeaderField: "X-OCBC-Version") == NetworkingConfig.fixture.appVersion)
    #expect(request.value(forHTTPHeaderField: "X-OCBC-APIKey") == NetworkingConfig.fixture.apiKey)
    #expect(request.value(forHTTPHeaderField: "X-OCBCNISP-OMNI-SESSION") == "SESSION123")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer TOKEN123")
    #expect(request.value(forHTTPHeaderField: "Nonce") == "nonce-123")
    #expect(request.value(forHTTPHeaderField: "X-OCBC-Timestamp") == "Fri Feb 27 07:15:22 GMT+01:00 2026")
    #expect(request.value(forHTTPHeaderField: "URI") == "/qris/account/primary")
    #expect(request.value(forHTTPHeaderField: "X-OCBC-Signature") == "SIGNED")
}

@Test
func execute_maps401_toUnauthorized() async throws {
    let recorder = RequestRecorder()
    let endpoint = TestEndpoint()
    let responseData = Data()
    let url = URL(string: "https://example.com")!
    let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (responseData, response))

    let client = APIClient(config: .fixture, httpClient: httpClient)

    do {
        _ = try await client.execute(endpoint)
        Issue.record("Expected execute to throw unauthorized")
    } catch let error as NetworkError {
        guard case .unauthorized = error else {
            Issue.record("Expected unauthorized, got \(error)")
            return
        }
    }
}

@Test
func execute_mapsDecodingErrors() async throws {
    let recorder = RequestRecorder()
    let endpoint = TestEndpoint()
    let invalidData = #"{"unexpected":"shape"}"#.data(using: .utf8)!
    let url = URL(string: "https://example.com")!
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (invalidData, response))

    let client = APIClient(config: .fixture, httpClient: httpClient)

    do {
        _ = try await client.execute(endpoint)
        Issue.record("Expected execute to throw decoding error")
    } catch let error as NetworkError {
        guard case .decoding = error else {
            Issue.record("Expected decoding error, got \(error)")
            return
        }
    }
}

private struct TestEndpoint: Endpoint {
    struct Response: Decodable, Equatable {
        let value: String
    }

    let path = "/qris/account/primary"
    let method: HTTPMethod = .get
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

    func makeNonce() -> String {
        value
    }
}

private struct FixedTimestampProvider: TimestampProvider {
    let value: String

    func now() -> Date {
        .distantPast
    }

    func string(from date: Date) -> String {
        value
    }
}

private struct FixedSessionProvider: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? {
        value
    }
}

private struct FixedAccessTokenProvider: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? {
        value
    }
}

private struct FixedSigner: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String {
        value
    }
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
