public struct WithdrawalAckRequest: Encodable, Sendable, Equatable {
    public typealias Amount = WithdrawalAmountValue

    public struct SourceOfFund: Encodable, Sendable, Equatable {
        public struct AccountBalance: Encodable, Sendable, Equatable {
            public let accountCcy: String
            public let balance: Double
            public let isAvailable: Bool

            public init(accountCcy: String, balance: Double, isAvailable: Bool) {
                self.accountCcy = accountCcy
                self.balance = balance
                self.isAvailable = isAvailable
            }
        }

        public let accountBalances: [AccountBalance]
        public let accountID: String
        public let accountNo: String
        public let accountType: String
        public let branchCode: String
        public let cif: String
        public let labelDebitAccount: String
        public let mcBit: String
        public let productCode: String
        public let productName: String

        public init(
            accountBalances: [AccountBalance],
            accountID: String,
            accountNo: String,
            accountType: String,
            branchCode: String,
            cif: String,
            labelDebitAccount: String,
            mcBit: String,
            productCode: String,
            productName: String
        ) {
            self.accountBalances = accountBalances
            self.accountID = accountID
            self.accountNo = accountNo
            self.accountType = accountType
            self.branchCode = branchCode
            self.cif = cif
            self.labelDebitAccount = labelDebitAccount
            self.mcBit = mcBit
            self.productCode = productCode
            self.productName = productName
        }

        enum CodingKeys: String, CodingKey {
            case accountBalances
            case accountID = "accountId"
            case accountNo
            case accountType
            case branchCode
            case cif
            case labelDebitAccount
            case mcBit
            case productCode
            case productName
        }
    }

    public let amount: Amount
    public let benePhoneNumber: String
    public let onlineSessionID: String
    public let pin: String
    public let remitterPhoneNumber: String
    public let responseCodeOTP: String
    public let sourceOfFund: SourceOfFund
    public let withdrawalType: String

    public init(
        amount: Amount,
        benePhoneNumber: String,
        onlineSessionID: String,
        pin: String,
        remitterPhoneNumber: String,
        responseCodeOTP: String,
        sourceOfFund: SourceOfFund,
        withdrawalType: String
    ) {
        self.amount = amount
        self.benePhoneNumber = benePhoneNumber
        self.onlineSessionID = onlineSessionID
        self.pin = pin
        self.remitterPhoneNumber = remitterPhoneNumber
        self.responseCodeOTP = responseCodeOTP
        self.sourceOfFund = sourceOfFund
        self.withdrawalType = withdrawalType
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case benePhoneNumber
        case onlineSessionID = "onlineSessionId"
        case pin
        case remitterPhoneNumber
        case responseCodeOTP
        case sourceOfFund
        case withdrawalType
    }
}
