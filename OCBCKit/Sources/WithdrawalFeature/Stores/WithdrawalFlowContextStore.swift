import Observation
import WithdrawalCore

@MainActor
@Observable
final class WithdrawalFlowContextStore {
    static let shared = WithdrawalFlowContextStore()

    var selectedSourceOfFund: WithdrawalSourceOfFundAccount?
    var validationResult: WithdrawalValidationResult?

    private init() {}

    func clear() {
        selectedSourceOfFund = nil
        validationResult = nil
    }
}
