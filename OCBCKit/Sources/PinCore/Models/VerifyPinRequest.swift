public struct VerifyPinRequest: Encodable, Sendable, Equatable {
    public let appliNumber: String
    public let otpCode: String
    public let sequenceNumber: String

    public init(appliNumber: String, otpCode: String, sequenceNumber: String) {
        self.appliNumber = appliNumber
        self.otpCode = otpCode
        self.sequenceNumber = sequenceNumber
    }
}
