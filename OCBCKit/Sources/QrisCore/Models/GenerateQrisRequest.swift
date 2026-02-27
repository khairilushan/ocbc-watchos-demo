public struct GenerateQrisRequest: Encodable, Sendable, Equatable {
    public let amount: Int?
    public let dynamicAccountID: String
    public let remark: String

    public init(amount: Int?, dynamicAccountID: String, remark: String) {
        self.amount = amount
        self.dynamicAccountID = dynamicAccountID
        self.remark = remark
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case dynamicAccountID = "dynamicAccountId"
        case remark
    }
}
