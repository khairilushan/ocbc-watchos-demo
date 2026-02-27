public struct BalanceCurrencyAccount: Sendable, Equatable {
    public let currencyCode: String
    public let accountCcyNameID: String
    public let accountCcyNameEN: String
    public let balance: Double
    public let isAvailable: Bool
    public let iconURL: String

    public init(
        currencyCode: String,
        accountCcyNameID: String,
        accountCcyNameEN: String,
        balance: Double,
        isAvailable: Bool,
        iconURL: String
    ) {
        self.currencyCode = currencyCode
        self.accountCcyNameID = accountCcyNameID
        self.accountCcyNameEN = accountCcyNameEN
        self.balance = balance
        self.isAvailable = isAvailable
        self.iconURL = iconURL
    }
}
