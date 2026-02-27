public struct QrisPrimaryAccount: Sendable, Equatable {
    public let qrCodePayload: String
    public let dynamicAccountID: String

    public init(qrCodePayload: String, dynamicAccountID: String) {
        self.qrCodePayload = qrCodePayload
        self.dynamicAccountID = dynamicAccountID
    }
}
