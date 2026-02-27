import Foundation
import Networking

public enum PreviewNetworkingValues {
    public static let baseURL = URL(string: "https://private-f0b751-byon.apiary-mock.com")!
    public static let apiKey = "d44d1365-128e-4485-a332-de5b074f4ca8"
    public static let userAgent = "iOS/4.4.4 (build:2020020202; iOS 26.0) URLSession"
    public static let acceptLanguage = "EN"
    public static let omniChannel = "iOS"
    public static let platform = "iOS"
    public static let appVersion = "4.4.4"
    public static let sessionID = "2A70E37432187D09D9A29897A16B4E11"
    public static let accessToken = "bffc9bfb-7925-4f17-baa0-9e51cb93bf6b"

    public static func signature(apiKey: String, nonce: String, timestamp: String, uri: String) -> String {
        Data("\(apiKey):\(nonce):\(timestamp):\(uri)".utf8).base64EncodedString()
    }

    public static func config(baseURL: URL = PreviewNetworkingValues.baseURL) -> NetworkingConfig {
        NetworkingConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            userAgent: userAgent,
            acceptLanguage: acceptLanguage,
            omniChannel: omniChannel,
            platform: platform,
            appVersion: appVersion
        )
    }

    public static func apiClient(baseURL: URL = PreviewNetworkingValues.baseURL) -> APIClient {
        APIClient(
            config: config(baseURL: baseURL),
            sessionProvider: PreviewSessionProvider(),
            accessTokenProvider: PreviewAccessTokenProvider(),
            headerProviders: [
                StaticHeadersProvider(),
                SessionHeadersProvider(),
                AuthorizationHeadersProvider(),
                SignatureHeadersProvider(signer: PreviewRequestSigner())
            ],
            interceptors: [
                NetworkLoggingInterceptor(logger: ConsoleNetworkLogger())
            ]
        )
    }
}

public struct PreviewSessionProvider: SessionProvider {
    public init() {}

    public func currentSessionID() async -> String? {
        PreviewNetworkingValues.sessionID
    }
}

public struct PreviewAccessTokenProvider: AccessTokenProvider {
    public init() {}

    public func currentAccessToken() async -> String? {
        PreviewNetworkingValues.accessToken
    }
}

public struct PreviewRequestSigner: RequestSigner {
    public init() {}

    public func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String {
        PreviewNetworkingValues.signature(apiKey: apiKey, nonce: nonce, timestamp: timestamp, uri: uri)
    }
}
