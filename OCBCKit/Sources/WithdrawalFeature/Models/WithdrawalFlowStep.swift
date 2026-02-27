enum WithdrawalFlowStep: Equatable {
    case input
    case pin
    case result(WithdrawalResultModel)
}
