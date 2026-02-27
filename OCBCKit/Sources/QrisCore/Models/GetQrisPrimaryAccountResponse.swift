import Foundation

public struct GetQrisPrimaryAccountResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public let isEligible: Bool
        public let account: Account

        public struct Account: Decodable, Sendable, Equatable {
            public let productCode: String
            public let productName: String
            public let accountName: String
            public let dynamicAccountId: String
            public let qrCode: String
        }
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription
        case data
    }
}
