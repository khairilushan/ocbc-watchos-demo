public struct WithdrawalAmountConfiguration: Sendable, Equatable {
    public var parameters: [WithdrawalAmountParameter]
    public var minimumAmount: Int
    public var maximumAmount: Int
    public var denominationAmount: Int

    public init(
        parameters: [WithdrawalAmountParameter],
        minimumAmount: Int,
        maximumAmount: Int,
        denominationAmount: Int
    ) {
        self.parameters = parameters
        self.minimumAmount = minimumAmount
        self.maximumAmount = maximumAmount
        self.denominationAmount = denominationAmount
    }
}

public struct WithdrawalAmountParameter: Sendable, Equatable {
    public var code: String
    public var value: String

    public init(code: String, value: String) {
        self.code = code
        self.value = value
    }
}
