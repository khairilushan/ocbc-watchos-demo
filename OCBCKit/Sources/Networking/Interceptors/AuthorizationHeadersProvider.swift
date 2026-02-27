public struct AuthorizationHeadersProvider: RequestHeaderProvider {
    public init() {}

    public func headers(config: NetworkingConfig, context: RequestContext) async throws -> [String: String] {
        guard let token = context.accessToken, !token.isEmpty else {
            return [:]
        }
        return ["Authorization": "Bearer \(token)"]
    }
}
