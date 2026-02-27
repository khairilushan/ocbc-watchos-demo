import Foundation

public struct NetworkingConfig: Sendable {
    public var baseURL: URL
    public var apiKey: String
    public var userAgent: String
    public var acceptLanguage: String
    public var omniChannel: String
    public var platform: String
    public var appVersion: String

    public init(
        baseURL: URL,
        apiKey: String,
        userAgent: String,
        acceptLanguage: String,
        omniChannel: String,
        platform: String,
        appVersion: String
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.userAgent = userAgent
        self.acceptLanguage = acceptLanguage
        self.omniChannel = omniChannel
        self.platform = platform
        self.appVersion = appVersion
    }
}
