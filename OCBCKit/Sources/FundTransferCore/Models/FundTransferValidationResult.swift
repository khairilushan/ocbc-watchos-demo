public struct FundTransferValidationResult: Sendable, Equatable {
    public let warningCode: String
    public let transactionId: String
    public let transferServiceCode: String
    public let onlineSessionId: String
    public let warningMessage: String

    public init(
        warningCode: String,
        transactionId: String,
        transferServiceCode: String,
        onlineSessionId: String,
        warningMessage: String
    ) {
        self.warningCode = warningCode
        self.transactionId = transactionId
        self.transferServiceCode = transferServiceCode
        self.onlineSessionId = onlineSessionId
        self.warningMessage = warningMessage
    }
}
