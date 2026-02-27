public struct WithdrawalValidationResult: Sendable, Equatable {
    public let withdrawalType: String
    public let remitterPhoneNumber: String
    public let benePhoneNumber: String
    public let pin: String
    public let amountCode: String
    public let amountValue: String
    public let sourceOfFundAccountNo: String
    public let onlineSessionId: String

    public init(
        withdrawalType: String,
        remitterPhoneNumber: String,
        benePhoneNumber: String,
        pin: String,
        amountCode: String,
        amountValue: String,
        sourceOfFundAccountNo: String,
        onlineSessionId: String
    ) {
        self.withdrawalType = withdrawalType
        self.remitterPhoneNumber = remitterPhoneNumber
        self.benePhoneNumber = benePhoneNumber
        self.pin = pin
        self.amountCode = amountCode
        self.amountValue = amountValue
        self.sourceOfFundAccountNo = sourceOfFundAccountNo
        self.onlineSessionId = onlineSessionId
    }
}
