public struct WithdrawalSourceOfFundAccount: Sendable, Equatable {
    public let productCode: String
    public let productName: String
    public let accountNo: String
    public let accountType: String
    public let accountCcy: String
    public let balance: Double
    public let isAvailable: Bool

    public init(
        productCode: String,
        productName: String,
        accountNo: String,
        accountType: String,
        accountCcy: String,
        balance: Double,
        isAvailable: Bool
    ) {
        self.productCode = productCode
        self.productName = productName
        self.accountNo = accountNo
        self.accountType = accountType
        self.accountCcy = accountCcy
        self.balance = balance
        self.isAvailable = isAvailable
    }
}
