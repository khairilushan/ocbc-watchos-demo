public protocol RequestHeaderProvider: Sendable {
    func headers(config: NetworkingConfig, context: RequestContext) async throws -> [String: String]
}
