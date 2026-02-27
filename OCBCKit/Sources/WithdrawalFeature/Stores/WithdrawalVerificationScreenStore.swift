import AppCore
import Dependencies
import Observation
import PinCore
import WithdrawalCore

@MainActor
@Observable
final class WithdrawalVerificationScreenStore {
    @ObservationIgnored
    @Dependency(\.withdrawalClient)
    private var withdrawalClient

    var state: ScreenState<WithdrawalResultModel> = .loading

    func task() async {
        guard
            let sourceOfFund = WithdrawalFlowContextStore.shared.selectedSourceOfFund,
            let validationResult = WithdrawalFlowContextStore.shared.validationResult
        else {
            state = .failure("Withdrawal context is missing.")
            return
        }

        do {
            let verifiedPin = await PinVerificationSession.shared.verifiedPin(for: validationResult.onlineSessionId) ?? ""
            let ackResult = try await withdrawalClient.acknowledge(
                makeAckRequest(
                    sourceOfFund: sourceOfFund,
                    validationResult: validationResult,
                    responseCodeOTP: verifiedPin
                )
            )
            state = .success(mapToResultUiModel(ackResult))
            WithdrawalFlowContextStore.shared.clear()
            await PinVerificationSession.shared.clear(for: validationResult.onlineSessionId)
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to process withdrawal verification.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToResultUiModel(_ data: WithdrawalAckResult) -> WithdrawalResultModel {
        WithdrawalResultModel(
            amountText: data.amountValue,
            transactionId: data.transactionId,
            transactionOtp: data.transactionOTP,
            tokenCard: data.tokenCard,
            title: data.messageTitle.isEmpty ? "Withdrawal Submitted" : data.messageTitle,
            subtitle: data.messageSubtitle.isEmpty ? data.responseDescription : data.messageSubtitle
        )
    }

    private func makeAckRequest(
        sourceOfFund: WithdrawalSourceOfFundAccount,
        validationResult: WithdrawalValidationResult,
        responseCodeOTP: String
    ) -> WithdrawalAckRequest {
        .init(
            amount: .init(code: validationResult.amountCode, value: validationResult.amountValue),
            benePhoneNumber: validationResult.benePhoneNumber,
            onlineSessionID: validationResult.onlineSessionId,
            pin: validationResult.pin,
            remitterPhoneNumber: validationResult.remitterPhoneNumber,
            responseCodeOTP: responseCodeOTP,
            sourceOfFund: .init(
                accountBalances: [
                    .init(
                        accountCcy: sourceOfFund.accountCcy,
                        balance: sourceOfFund.balance,
                        isAvailable: sourceOfFund.isAvailable
                    )
                ],
                accountID: "",
                accountNo: sourceOfFund.accountNo,
                accountType: sourceOfFund.accountType,
                branchCode: "99693",
                cif: "",
                labelDebitAccount: sourceOfFund.productName,
                mcBit: "Y",
                productCode: sourceOfFund.productCode,
                productName: sourceOfFund.productName
            ),
            withdrawalType: validationResult.withdrawalType
        )
    }
}
