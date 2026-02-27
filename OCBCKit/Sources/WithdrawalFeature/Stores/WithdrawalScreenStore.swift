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
    var flowStep: WithdrawalFlowStep = .input
    var isAmountSheetPresented = false
    var pin = ""
    var isSubmitting = false

    private var selectedSourceOfFund: WithdrawalSourceOfFundAccount?
    private var validationResult: WithdrawalValidationResult?

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
            flowStep = .input
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
        flowStep = .input
        pin = ""
        validationResult = nil
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

    func confirmButtonTapped() async {
        guard !isSubmitting else { return }
        guard let model = state[case: \.success], let sourceOfFund = selectedSourceOfFund else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let request = makeValidationRequest(sourceOfFund: sourceOfFund, amount: model.selectedAmount)
            validationResult = try await withdrawalClient.validate(request)
            pin = ""
            flowStep = .pin
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to validate withdrawal request.")
        }
    }

    func pinConfirmButtonTapped() async {
        guard !isSubmitting else { return }
        guard let sourceOfFund = selectedSourceOfFund, let validationResult else { return }
        guard pin.count == 6 else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let pinResult = try await withdrawalClient.verifyPinOTP(
                .init(appliNumber: validationResult.onlineSessionId, otpCode: pin, sequenceNumber: "0")
            )
            let ackResult = try await withdrawalClient.acknowledge(
                makeAckRequest(
                    sourceOfFund: sourceOfFund,
                    validationResult: validationResult,
                    responseCodeOTP: pinResult.responseCode
                )
            )
            flowStep = .result(mapToResultUiModel(ackResult))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to verify PIN.")
        }
    }

    func backToInputButtonTapped() {
        flowStep = .input
        pin = ""
    }

    private func mapToSourceOfFundUiModel(_ source: WithdrawalSourceOfFundAccount) -> WithdrawalSourceOfFundUiModel {
        WithdrawalSourceOfFundUiModel(
            productName: source.productName,
            accountNo: mask(accountNo: source.accountNo),
            accountCurrency: source.accountCcy,
            balanceText: formatCurrency(balance: source.balance)
        )
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
