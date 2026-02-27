public protocol AccessTokenProvider: Sendable {
    func currentAccessToken() async -> String?
}

public struct EmptyAccessTokenProvider: AccessTokenProvider {
    public init() {}

    public func currentAccessToken() async -> String? {
        nil
    }
}
