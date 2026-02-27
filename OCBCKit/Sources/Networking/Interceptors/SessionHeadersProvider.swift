public struct SessionHeadersProvider: RequestHeaderProvider {
    public init() {}

    public func headers(config: NetworkingConfig, context: RequestContext) async throws -> [String: String] {
        guard let sessionID = context.sessionID, !sessionID.isEmpty else {
            return [:]
        }
        return ["X-OCBCNISP-OMNI-SESSION": sessionID]
    }
}
