import Foundation

public struct InquiryBalanceTotalResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescEn: String
    public let responseDescId: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public let listAccountBalanceByCIF: [BalanceItem]
    }

    public struct BalanceItem: Decodable, Sendable, Equatable {
        public let accountCcyNameID: String
        public let accountCcyNameEN: String
        public let accountCcy: String
        public let balance: Double
        public let isAvailable: Bool
        public let iconURL: String

        enum CodingKeys: String, CodingKey {
            case accountCcyNameID
            case accountCcyNameEN
            case accountCcy
            case balance
            case isAvailable
            case iconURL = "iconUrl"
        }
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescEn = "response_desc_en"
        case responseDescId = "response_desc_id"
        case data
    }
}
