public struct PostWithdrawalValidationResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public let withdrawalType: String
        public let remitterPhoneNumber: String
        public let benePhoneNumber: String
        public let pin: String
        public let onlineSessionId: String
        public let amount: WithdrawalAmountValue
        public let sourceOfFund: SourceOfFund

        public struct SourceOfFund: Decodable, Sendable, Equatable {
            public let productCode: String
            public let productName: String
            public let accountNo: String
            public let accountType: String
            public let accountId: String
            public let labelDebitAccount: String
            public let accountBalances: [AccountBalance]

            public struct AccountBalance: Decodable, Sendable, Equatable {
                public let accountCcy: String
                public let balance: Double
                public let isAvailable: Bool
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription
        case data
    }
}
