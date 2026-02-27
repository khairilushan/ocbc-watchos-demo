import Foundation

public struct GetWithdrawalSourceOfFundsResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public let accounts: [Account]

        public struct Account: Decodable, Sendable, Equatable {
            public let productCode: String
            public let productName: String
            public let accountNo: String
            public let accountType: String
            public let accountBalances: [AccountBalance]

            public struct AccountBalance: Decodable, Sendable, Equatable {
                public let accountCcy: String
                public let balance: Double
                public let holdBalance: Double
                public let isAvailable: Bool
                public let accountCcyNameID: String
                public let accountCcyNameEN: String
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription
        case data
    }
}
