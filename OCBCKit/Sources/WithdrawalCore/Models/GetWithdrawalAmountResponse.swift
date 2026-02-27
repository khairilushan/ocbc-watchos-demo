import Foundation

public struct GetWithdrawalAmountResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public let parameters: [Parameter]
        public let minimumAmount: Int
        public let maximumAmount: Int
        public let denominationAmount: Int

        public struct Parameter: Decodable, Sendable, Equatable {
            public let code: String
            public let value: String
        }
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription
        case data
    }
}
