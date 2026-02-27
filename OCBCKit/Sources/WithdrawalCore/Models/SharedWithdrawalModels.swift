public struct WithdrawalAmountValue: Codable, Sendable, Equatable {
    public let code: String
    public let value: String

    public init(code: String, value: String) {
        self.code = code
        self.value = value
    }
}
