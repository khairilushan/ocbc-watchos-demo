import AppCore
import Dependencies
import Foundation
import Observation
import WithdrawalCore

@MainActor
@Observable
final class WithdrawalScreenStore {
    @ObservationIgnored
    @Dependency(\.withdrawalClient)
    private var withdrawalClient

    var state: ScreenState<WithdrawalInputModel> = .loading
    var isAmountSheetPresented = false
    var isSubmitting = false

    private var selectedSourceOfFund: WithdrawalSourceOfFundAccount?

    func task() async {
        do {
            async let sourceOfFundsTask = withdrawalClient.fetchSourceOfFunds()
            async let amountsTask = withdrawalClient.fetchAmountConfiguration(.otp)

            let (sourceOfFunds, amountConfiguration) = try await (sourceOfFundsTask, amountsTask)
            guard let sourceOfFund = sourceOfFunds.first(where: \.isAvailable) ?? sourceOfFunds.first else {
                state = .failure("No source of funds available.")
                return
            }

            let amountOptions = amountConfiguration.parameters.map {
                WithdrawalAmountOption(code: $0.code, value: $0.value)
            }
            guard let selectedAmount = amountOptions.first else {
                state = .failure("No withdrawal amount available.")
                return
            }

            selectedSourceOfFund = sourceOfFund
            state = .success(
                WithdrawalInputModel(
                    sourceOfFund: mapToSourceOfFundUiModel(sourceOfFund),
                    amountOptions: amountOptions,
                    selectedAmount: selectedAmount
                )
            )
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load withdrawal data.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        WithdrawalFlowContextStore.shared.clear()
        await task()
    }

    func amountButtonTapped() {
        isAmountSheetPresented = true
    }

    func amountSelected(_ option: WithdrawalAmountOption) {
        guard var model = state[case: \.success] else { return }
        model.selectedAmount = option
        state = .success(model)
        isAmountSheetPresented = false
    }

    func confirmButtonTapped() async -> Destination? {
        guard !isSubmitting else { return nil }
        guard let model = state[case: \.success], let sourceOfFund = selectedSourceOfFund else { return nil }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let request = makeValidationRequest(sourceOfFund: sourceOfFund, amount: model.selectedAmount)
            let validationResult = try await withdrawalClient.validate(request)
            WithdrawalFlowContextStore.shared.selectedSourceOfFund = sourceOfFund
            WithdrawalFlowContextStore.shared.validationResult = validationResult
            return .pin(
                appliNumber: validationResult.onlineSessionId,
                sequenceNumber: "0",
                next: .withdrawalVerification
            )
        } catch is CancellationError {
            return nil
        } catch {
            state = .failure("Failed to validate withdrawal request.")
            return nil
        }
    }

    private func mapToSourceOfFundUiModel(_ source: WithdrawalSourceOfFundAccount) -> WithdrawalSourceOfFundUiModel {
        WithdrawalSourceOfFundUiModel(
            productName: source.productName,
            accountNo: mask(accountNo: source.accountNo),
            accountCurrency: source.accountCcy,
            balanceText: formatCurrency(balance: source.balance)
        )
    }

    private func makeValidationRequest(
        sourceOfFund: WithdrawalSourceOfFundAccount,
        amount: WithdrawalAmountOption
    ) -> WithdrawalValidationRequest {
        .init(
            amount: .init(code: amount.code, value: amount.value),
            benePhoneNumber: "",
            pin: "",
            remitterPhoneNumber: "",
            sourceOfFund: .init(
                productCode: sourceOfFund.productCode,
                productName: sourceOfFund.productName,
                accountNo: sourceOfFund.accountNo,
                accountType: sourceOfFund.accountType,
                bankCode: "999",
                branchCode: "99693",
                mcBit: "Y",
                dynamicAccountId: "",
                accountBalances: [
                    .init(
                        accountCcy: sourceOfFund.accountCcy,
                        accountCcyNameEN: sourceOfFund.accountCcy,
                        accountCcyNameID: sourceOfFund.accountCcy,
                        balance: sourceOfFund.balance,
                        holdBalance: 0,
                        isAvailable: sourceOfFund.isAvailable
                    )
                ]
            ),
            withdrawalType: WithdrawalType.otp.rawValue
        )
    }

    private func mask(accountNo: String) -> String {
        let suffix = accountNo.suffix(4)
        return "**** \(suffix)"
    }

    private func formatCurrency(balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.currencySymbol = "IDR "
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: NSNumber(value: balance)) ?? "IDR \(Int(balance))"
    }
}
