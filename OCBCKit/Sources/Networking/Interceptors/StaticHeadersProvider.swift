public struct StaticHeadersProvider: RequestHeaderProvider {
    public init() {}

    public func headers(config: NetworkingConfig, context: RequestContext) async throws -> [String: String] {
        [
            "User-Agent": config.userAgent,
            "Accept-Language": config.acceptLanguage,
            "X-OCBCNISP-OMNI-CHANNEL": config.omniChannel,
            "X-OCBC-Platform": config.platform,
            "X-OCBC-Version": config.appVersion,
            "X-OCBC-APIKey": config.apiKey
        ]
    }
}
