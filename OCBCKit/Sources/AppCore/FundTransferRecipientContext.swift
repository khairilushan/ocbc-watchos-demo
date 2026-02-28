public struct FundTransferRecipientContext: Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let bankName: String
    public let accountNo: String
    public let accountCurrency: String

    public init(
        id: String,
        displayName: String,
        bankName: String,
        accountNo: String,
        accountCurrency: String
    ) {
        self.id = id
        self.displayName = displayName
        self.bankName = bankName
        self.accountNo = accountNo
        self.accountCurrency = accountCurrency
    }
}
