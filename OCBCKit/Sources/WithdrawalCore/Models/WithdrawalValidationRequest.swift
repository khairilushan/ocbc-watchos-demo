public struct WithdrawalValidationRequest: Encodable, Sendable, Equatable {
    public typealias Amount = WithdrawalAmountValue

    public struct SourceOfFund: Encodable, Sendable, Equatable {
        public struct AccountBalance: Encodable, Sendable, Equatable {
            public let accountCcy: String
            public let accountCcyNameEN: String
            public let accountCcyNameID: String
            public let balance: Double
            public let holdBalance: Double
            public let isAvailable: Bool

            public init(
                accountCcy: String,
                accountCcyNameEN: String,
                accountCcyNameID: String,
                balance: Double,
                holdBalance: Double,
                isAvailable: Bool
            ) {
                self.accountCcy = accountCcy
                self.accountCcyNameEN = accountCcyNameEN
                self.accountCcyNameID = accountCcyNameID
                self.balance = balance
                self.holdBalance = holdBalance
                self.isAvailable = isAvailable
            }
        }

        public let productCode: String
        public let productName: String
        public let accountNo: String
        public let accountType: String
        public let bankCode: String
        public let branchCode: String
        public let mcBit: String
        public let dynamicAccountId: String
        public let accountBalances: [AccountBalance]

        public init(
            productCode: String,
            productName: String,
            accountNo: String,
            accountType: String,
            bankCode: String,
            branchCode: String,
            mcBit: String,
            dynamicAccountId: String,
            accountBalances: [AccountBalance]
        ) {
            self.productCode = productCode
            self.productName = productName
            self.accountNo = accountNo
            self.accountType = accountType
            self.bankCode = bankCode
            self.branchCode = branchCode
            self.mcBit = mcBit
            self.dynamicAccountId = dynamicAccountId
            self.accountBalances = accountBalances
        }
    }

    public let amount: Amount
    public let benePhoneNumber: String
    public let pin: String
    public let remitterPhoneNumber: String
    public let sourceOfFund: SourceOfFund
    public let withdrawalType: String

    public init(
        amount: Amount,
        benePhoneNumber: String,
        pin: String,
        remitterPhoneNumber: String,
        sourceOfFund: SourceOfFund,
        withdrawalType: String
    ) {
        self.amount = amount
        self.benePhoneNumber = benePhoneNumber
        self.pin = pin
        self.remitterPhoneNumber = remitterPhoneNumber
        self.sourceOfFund = sourceOfFund
        self.withdrawalType = withdrawalType
    }
}
