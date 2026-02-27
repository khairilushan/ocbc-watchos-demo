public struct PostWithdrawalAckResponse: Decodable, Sendable, Equatable {
    public struct DataPayload: Decodable, Sendable, Equatable {
        public struct Message: Decodable, Sendable, Equatable {
            public let title: String
            public let subtitle: String
        }

        public let amount: WithdrawalAmountValue
        public let transactionId: String
        public let transactionOTP: String
        public let tokenCard: String
        public let message: Message

        enum CodingKeys: String, CodingKey {
            case amount
            case transactionId
            case transactionOTP = "transactionOtp"
            case tokenCard
            case message
        }
    }

    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription
        case data
    }
}
