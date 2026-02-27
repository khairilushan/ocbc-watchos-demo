public struct QrisPrimaryAccount: Sendable, Equatable {
    public let qrCodePayload: String

    public init(qrCodePayload: String) {
        self.qrCodePayload = qrCodePayload
    }
}
