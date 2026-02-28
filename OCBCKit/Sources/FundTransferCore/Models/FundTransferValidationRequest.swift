public struct FundTransferValidationRequest: Encodable, Sendable, Equatable {
    public struct SourceAccount: Encodable, Sendable, Equatable {
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

        public let accountNo: String
        public let accountName: String
        public let accountType: String
        public let dynamicAccountId: String
        public let productCode: String
        public let productName: String
        public let accountBalances: [AccountBalance]

        public init(
            accountNo: String,
            accountName: String,
            accountType: String,
            dynamicAccountId: String,
            productCode: String,
            productName: String,
            accountBalances: [AccountBalance]
        ) {
            self.accountNo = accountNo
            self.accountName = accountName
            self.accountType = accountType
            self.dynamicAccountId = dynamicAccountId
            self.productCode = productCode
            self.productName = productName
            self.accountBalances = accountBalances
        }
    }

    public struct NonRegisteredAccount: Encodable, Sendable, Equatable {
        public struct BeneAccount: Encodable, Sendable, Equatable {
            public struct AccountBalance: Encodable, Sendable, Equatable {
                public let accountCcy: String

                public init(accountCcy: String) {
                    self.accountCcy = accountCcy
                }
            }

            public let accountNo: String
            public let accountName: String
            public let accountBalances: [AccountBalance]
            public let bankCode: String
            public let bankName: String

            public init(
                accountNo: String,
                accountName: String,
                accountBalances: [AccountBalance],
                bankCode: String,
                bankName: String
            ) {
                self.accountNo = accountNo
                self.accountName = accountName
                self.accountBalances = accountBalances
                self.bankCode = bankCode
                self.bankName = bankName
            }
        }

        public struct BeneTransaction: Encodable, Sendable, Equatable {
            public let transferServiceCode: String
            public let amount: String
            public let amountCcy: String
            public let interval: String
            public let recurStartDate: String
            public let recurEndDate: String
            public let remark: String
            public let transferDate: String

            public init(
                transferServiceCode: String,
                amount: String,
                amountCcy: String,
                interval: String,
                recurStartDate: String,
                recurEndDate: String,
                remark: String,
                transferDate: String
            ) {
                self.transferServiceCode = transferServiceCode
                self.amount = amount
                self.amountCcy = amountCcy
                self.interval = interval
                self.recurStartDate = recurStartDate
                self.recurEndDate = recurEndDate
                self.remark = remark
                self.transferDate = transferDate
            }
        }

        public let beneAccount: BeneAccount
        public let beneTransaction: BeneTransaction

        public init(beneAccount: BeneAccount, beneTransaction: BeneTransaction) {
            self.beneAccount = beneAccount
            self.beneTransaction = beneTransaction
        }
    }

    public let responseCodeOTP: String
    public let sourceAccount: SourceAccount
    public let listNonRegisteredAccount: [NonRegisteredAccount]

    public init(
        responseCodeOTP: String,
        sourceAccount: SourceAccount,
        listNonRegisteredAccount: [NonRegisteredAccount]
    ) {
        self.responseCodeOTP = responseCodeOTP
        self.sourceAccount = sourceAccount
        self.listNonRegisteredAccount = listNonRegisteredAccount
    }
}
