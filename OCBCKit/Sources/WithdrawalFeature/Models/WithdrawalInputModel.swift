struct WithdrawalInputModel: Equatable {
    let sourceOfFund: WithdrawalSourceOfFundUiModel
    let amountOptions: [WithdrawalAmountOption]
    var selectedAmount: WithdrawalAmountOption
}
