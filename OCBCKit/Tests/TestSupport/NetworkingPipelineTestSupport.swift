import Foundation
import Networking

public actor RequestRecorder {
    private var request: URLRequest?

    public init() {}

    public func set(request: URLRequest) {
        self.request = request
    }

    public func latestRequest() -> URLRequest? {
        request
    }
}

public struct SpyHTTPClient: HTTPClient {
    public let recorder: RequestRecorder
    public let result: (Data, URLResponse)

    public init(recorder: RequestRecorder, result: (Data, URLResponse)) {
        self.recorder = recorder
        self.result = result
    }

    public func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

public struct FixedNonceGenerator: NonceGenerator {
    public let value: String

    public init(value: String) {
        self.value = value
    }

    public func makeNonce() -> String { value }
}

public struct FixedTimestampProvider: TimestampProvider {
    public let value: String

    public init(value: String) {
        self.value = value
    }

    public func now() -> Date { .distantPast }

    public func string(from date: Date) -> String { value }
}

public struct FixedSessionProvider: SessionProvider {
    public let value: String?

    public init(value: String?) {
        self.value = value
    }

    public func currentSessionID() async -> String? { value }
}

public struct FixedAccessTokenProvider: AccessTokenProvider {
    public let value: String?

    public init(value: String?) {
        self.value = value
    }

    public func currentAccessToken() async -> String? { value }
}

public struct FixedSigner: RequestSigner {
    public let value: String

    public init(value: String) {
        self.value = value
    }

    public func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

public extension NetworkingConfig {
    static var testFixture: Self {
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
