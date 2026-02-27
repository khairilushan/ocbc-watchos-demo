public struct SignatureHeadersProvider: RequestHeaderProvider {
    private let signer: any RequestSigner

    public init(signer: any RequestSigner) {
        self.signer = signer
    }

    public func headers(config: NetworkingConfig, context: RequestContext) async throws -> [String: String] {
        let signature = try signer.sign(
            apiKey: config.apiKey,
            nonce: context.nonce,
            timestamp: context.timestamp,
            uri: context.uri
        )

        return [
            "Nonce": context.nonce,
            "X-OCBC-Timestamp": context.timestamp,
            "URI": context.uri,
            "X-OCBC-Signature": signature
        ]
    }
}
