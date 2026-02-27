public struct RequestContext: Sendable {
    public var nonce: String
    public var timestamp: String
    public var uri: String
    public var sessionID: String?
    public var accessToken: String?

    public init(
        nonce: String,
        timestamp: String,
        uri: String,
        sessionID: String? = nil,
        accessToken: String? = nil
    ) {
        self.nonce = nonce
        self.timestamp = timestamp
        self.uri = uri
        self.sessionID = sessionID
        self.accessToken = accessToken
    }
}
