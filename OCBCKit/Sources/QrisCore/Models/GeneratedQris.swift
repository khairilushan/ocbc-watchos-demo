public struct GeneratedQris: Sendable, Equatable {
    public let encodedQRCode: String
    public let minimumAmount: Int
    public let maximumAmount: Int

    public init(encodedQRCode: String, minimumAmount: Int, maximumAmount: Int) {
        self.encodedQRCode = encodedQRCode
        self.minimumAmount = minimumAmount
        self.maximumAmount = maximumAmount
    }
}
