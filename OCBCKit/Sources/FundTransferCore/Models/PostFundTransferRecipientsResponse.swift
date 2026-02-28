import Foundation

public struct PostFundTransferRecipientsResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescription: String
    public let data: DataPayload

    public struct DataPayload: Decodable, Sendable, Equatable {
        public let recipients: [Recipient]
        public let pagination: Pagination

        public struct Recipient: Decodable, Sendable, Equatable {
            public let id: String
            public let accountNo: String
            public let accountName: String
            public let accountFullname: String
            public let nickname: String
            public let isFavorite: Bool
            public let bank: Bank
            public let transferCategory: String
            public let citizenship: Citizenship

            public struct Bank: Decodable, Sendable, Equatable {
                public let bankId: String
                public let swiftCode: String
                public let bankName: String
            }

            public struct Citizenship: Decodable, Sendable, Equatable {
                public let code: String
                public let value: String
                public let description: String
            }

            enum CodingKeys: String, CodingKey {
                case id
                case accountNo
                case accountName
                case accountFullname
                case nickname
                case isFavorite
                case isFavourite
                case bank
                case transferCategory
                case citizenship
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                accountNo = try container.decode(String.self, forKey: .accountNo)
                accountName = try container.decode(String.self, forKey: .accountName)
                accountFullname = try container.decode(String.self, forKey: .accountFullname)
                nickname = try container.decode(String.self, forKey: .nickname)
                let favorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
                let favourite = try container.decodeIfPresent(Bool.self, forKey: .isFavourite)
                isFavorite = favorite ?? favourite ?? false
                bank = try container.decode(Bank.self, forKey: .bank)
                transferCategory = try container.decode(String.self, forKey: .transferCategory)
                citizenship = try container.decode(Citizenship.self, forKey: .citizenship)
            }
        }

        public struct Pagination: Decodable, Sendable, Equatable {
            public let pageNumber: Int
            public let pageSize: Int
            public let totalData: Int
        }
    }

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescription = "response_desc_en"
        case data
    }
}
