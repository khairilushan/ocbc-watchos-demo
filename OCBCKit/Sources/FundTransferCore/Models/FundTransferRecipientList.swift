public struct FundTransferRecipientList: Sendable, Equatable {
    public let recipients: [FundTransferRecipient]
    public let pagination: FundTransferPagination

    public init(recipients: [FundTransferRecipient], pagination: FundTransferPagination) {
        self.recipients = recipients
        self.pagination = pagination
    }
}

public struct FundTransferRecipient: Sendable, Equatable {
    public let id: String
    public let accountNo: String
    public let accountName: String
    public let accountFullname: String
    public let nickname: String
    public let isFavorite: Bool
    public let bankId: String
    public let swiftCode: String
    public let bankName: String
    public let transferCategory: String
    public let citizenshipCode: String
    public let citizenshipValue: String
    public let citizenshipDescription: String

    public init(
        id: String,
        accountNo: String,
        accountName: String,
        accountFullname: String,
        nickname: String,
        isFavorite: Bool,
        bankId: String,
        swiftCode: String,
        bankName: String,
        transferCategory: String,
        citizenshipCode: String,
        citizenshipValue: String,
        citizenshipDescription: String
    ) {
        self.id = id
        self.accountNo = accountNo
        self.accountName = accountName
        self.accountFullname = accountFullname
        self.nickname = nickname
        self.isFavorite = isFavorite
        self.bankId = bankId
        self.swiftCode = swiftCode
        self.bankName = bankName
        self.transferCategory = transferCategory
        self.citizenshipCode = citizenshipCode
        self.citizenshipValue = citizenshipValue
        self.citizenshipDescription = citizenshipDescription
    }
}

public struct FundTransferPagination: Sendable, Equatable {
    public let pageNumber: Int
    public let pageSize: Int
    public let totalData: Int

    public init(pageNumber: Int, pageSize: Int, totalData: Int) {
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.totalData = totalData
    }
}
