import Foundation

public struct FundTransferRecipientSearchRequest: Encodable, Sendable, Equatable {
    public let category: String
    public let keyword: String
    public let menu: Menu
    public let pagination: Pagination

    public init(
        category: String,
        keyword: String = "",
        menu: Menu = .empty,
        pagination: Pagination
    ) {
        self.category = category
        self.keyword = keyword
        self.menu = menu
        self.pagination = pagination
    }

    public struct Menu: Encodable, Sendable, Equatable {
        public let actionCode: String
        public let description: String
        public let fields: [String]
        public let imageUrl: String
        public let id: String
        public let isAvailable: Bool
        public let isNeedAdditionalInformation: Bool
        public let isNew: Bool
        public let journey: String
        public let predefinedCategory: PredefinedCategory
        public let searchKeywords: [String]
        public let title: String
        public let type: String
        public let url: String
        public let value: String
        public let valueColor: String

        public init(
            actionCode: String,
            description: String,
            fields: [String],
            imageUrl: String,
            id: String,
            isAvailable: Bool,
            isNeedAdditionalInformation: Bool,
            isNew: Bool,
            journey: String,
            predefinedCategory: PredefinedCategory,
            searchKeywords: [String],
            title: String,
            type: String,
            url: String,
            value: String,
            valueColor: String
        ) {
            self.actionCode = actionCode
            self.description = description
            self.fields = fields
            self.imageUrl = imageUrl
            self.id = id
            self.isAvailable = isAvailable
            self.isNeedAdditionalInformation = isNeedAdditionalInformation
            self.isNew = isNew
            self.journey = journey
            self.predefinedCategory = predefinedCategory
            self.searchKeywords = searchKeywords
            self.title = title
            self.type = type
            self.url = url
            self.value = value
            self.valueColor = valueColor
        }

        public static let empty = Menu(
            actionCode: "",
            description: "",
            fields: [],
            imageUrl: "",
            id: "",
            isAvailable: false,
            isNeedAdditionalInformation: false,
            isNew: false,
            journey: "",
            predefinedCategory: .empty,
            searchKeywords: [],
            title: "",
            type: "",
            url: "",
            value: "",
            valueColor: ""
        )

        public struct PredefinedCategory: Encodable, Sendable, Equatable {
            public let additionalFields: [String]
            public let description: String
            public let iconUrl: String
            public let id: String
            public let isEnabled: Bool
            public let isSinglePayment: Bool
            public let minimumAmount: Int
            public let sectionTitle: String
            public let title: String
            public let type: String

            public init(
                additionalFields: [String],
                description: String,
                iconUrl: String,
                id: String,
                isEnabled: Bool,
                isSinglePayment: Bool,
                minimumAmount: Int,
                sectionTitle: String,
                title: String,
                type: String
            ) {
                self.additionalFields = additionalFields
                self.description = description
                self.iconUrl = iconUrl
                self.id = id
                self.isEnabled = isEnabled
                self.isSinglePayment = isSinglePayment
                self.minimumAmount = minimumAmount
                self.sectionTitle = sectionTitle
                self.title = title
                self.type = type
            }

            public static let empty = PredefinedCategory(
                additionalFields: [],
                description: "",
                iconUrl: "",
                id: "",
                isEnabled: false,
                isSinglePayment: false,
                minimumAmount: 0,
                sectionTitle: "",
                title: "",
                type: ""
            )
        }
    }

    public struct Pagination: Encodable, Sendable, Equatable {
        public let pageNumber: Int
        public let pageSize: Int
        public let totalData: Int

        public init(pageNumber: Int, pageSize: Int, totalData: Int = 0) {
            self.pageNumber = pageNumber
            self.pageSize = pageSize
            self.totalData = totalData
        }
    }
}
