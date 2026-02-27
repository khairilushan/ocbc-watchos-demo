public protocol SessionProvider: Sendable {
    func currentSessionID() async -> String?
}

public struct EmptySessionProvider: SessionProvider {
    public init() {}

    public func currentSessionID() async -> String? {
        nil
    }
}
