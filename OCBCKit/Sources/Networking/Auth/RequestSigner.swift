public protocol RequestSigner: Sendable {
    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String
}

public struct EmptyRequestSigner: RequestSigner {
    public init() {}

    public func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String {
        ""
    }
}
