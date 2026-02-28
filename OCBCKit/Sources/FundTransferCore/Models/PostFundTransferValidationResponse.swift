public struct PostFundTransferValidationResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public struct ValidationAccount: Decodable, Sendable, Equatable {
            public let accountNo: String
            public let accountName: String
            public let bankCode: String?
            public let bankName: String?
        }

        public struct ValidationTransaction: Decodable, Sendable, Equatable {
            public let id: String
            public let warningMessage: String?
            public let transferServiceCode: String
            public let amount: String
            public let amountCcy: String
            public let transferDate: String?
            public let onlineSessionId: String?
        }

        public struct NonRegisteredAccount: Decodable, Sendable, Equatable {
            public let beneAccount: ValidationAccount
            public let beneTransaction: ValidationTransaction
        }

        public let warningCode: String?
        public let sourceAccount: ValidationAccount
        public let listNonRegisteredAccount: [NonRegisteredAccount]
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription = "response_desc_en"
        case data
    }
}
