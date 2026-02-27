public struct WithdrawalAckResult: Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let amountCode: String
    public let amountValue: String
    public let transactionId: String
    public let transactionOTP: String
    public let tokenCard: String
    public let messageTitle: String
    public let messageSubtitle: String

    public init(
        responseCode: String,
        responseDescription: String,
        amountCode: String,
        amountValue: String,
        transactionId: String,
        transactionOTP: String,
        tokenCard: String,
        messageTitle: String,
        messageSubtitle: String
    ) {
        self.responseCode = responseCode
        self.responseDescription = responseDescription
        self.amountCode = amountCode
        self.amountValue = amountValue
        self.transactionId = transactionId
        self.transactionOTP = transactionOTP
        self.tokenCard = tokenCard
        self.messageTitle = messageTitle
        self.messageSubtitle = messageSubtitle
    }
}
