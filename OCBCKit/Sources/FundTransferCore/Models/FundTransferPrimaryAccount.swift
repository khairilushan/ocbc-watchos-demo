public struct FundTransferPrimaryAccount: Sendable, Equatable {
    public let hasDefaultAccount: Bool
    public let productCode: String
    public let productName: String
    public let accountNo: String
    public let accountType: String
    public let accountName: String
    public let dynamicAccountId: String
    public let qrCodePayload: String
    public let accountCcy: String
    public let balance: Double
    public let isAvailable: Bool

    public init(
        hasDefaultAccount: Bool,
        productCode: String,
        productName: String,
        accountNo: String,
        accountType: String,
        accountName: String,
        dynamicAccountId: String,
        qrCodePayload: String,
        accountCcy: String,
        balance: Double,
        isAvailable: Bool
    ) {
        self.hasDefaultAccount = hasDefaultAccount
        self.productCode = productCode
        self.productName = productName
        self.accountNo = accountNo
        self.accountType = accountType
        self.accountName = accountName
        self.dynamicAccountId = dynamicAccountId
        self.qrCodePayload = qrCodePayload
        self.accountCcy = accountCcy
        self.balance = balance
        self.isAvailable = isAvailable
    }
}
