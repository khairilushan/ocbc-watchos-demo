import AppCore
import Dependencies
import FundTransferCore
import Foundation
import Observation

@MainActor
@Observable
final class FundTransferAmountInputScreenStore {
    @ObservationIgnored
    @Dependency(\.fundTransferClient)
    private var fundTransferClient

    let recipient: FundTransferRecipientContext

    var isAmountKeypadPresented = false
    var amount: Int?
    var message = ""
    var selectedTransactionTime: FundTransferTransactionTimeOption = .now
    var sourceOfFund: FundTransferPrimaryAccount?
    var isSubmitting = false
    var continueErrorMessage: String?

    private let maxMessageLength = 25

    init(recipient: FundTransferRecipientContext) {
        self.recipient = recipient
    }

    func task() async {
        do {
            sourceOfFund = try await fundTransferClient.fetchPrimaryAccount()
        } catch is CancellationError {
        } catch {
            sourceOfFund = nil
        }
    }

    func continueButtonTapped() async -> Destination? {
        guard canContinue, let amount, let sourceOfFund else { return nil }
        isSubmitting = true
        continueErrorMessage = nil
        defer { isSubmitting = false }

        do {
            let request = buildValidationRequest(amount: amount, sourceOfFund: sourceOfFund)
            let result = try await fundTransferClient.validateTransfer(request)
            return .pin(
                appliNumber: result.onlineSessionId,
                sequenceNumber: "0",
                next: .home
            )
        } catch is CancellationError {
            return nil
        } catch {
            continueErrorMessage = "Failed to validate transfer."
            return nil
        }
    }

    var canContinue: Bool {
        guard let amount else { return false }
        return amount > 0
    }

    var formattedAmount: String {
        guard let amount else { return "IDR 0" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "IDR \(formatted)"
    }

    var recipientDisplayName: String {
        recipient.displayName
    }

    var recipientSecondaryText: String {
        recipient.bankName
    }

    var recipientAccountText: String {
        "\(maskedAccountNo(recipient.accountNo)) (\(recipient.accountCurrency))"
    }

    var sourceOfFundTitle: String {
        sourceOfFund?.productName ?? "Source Funds"
    }

    var sourceOfFundAccountText: String {
        guard let sourceOfFund else { return "Not available" }
        return "\(maskedAccountNo(sourceOfFund.accountNo)) (\(sourceOfFund.accountCcy))"
    }

    var sourceOfFundBalanceText: String {
        guard let sourceOfFund else { return "" }
        return "Balance \(formattedCurrency(sourceOfFund.balance, currency: sourceOfFund.accountCcy))"
    }

    var messageCountText: String {
        "\(message.count)/\(maxMessageLength)"
    }

    func amountButtonTapped() {
        isAmountKeypadPresented = true
    }

    func amountSelected(_ amount: Int?) {
        self.amount = amount
        isAmountKeypadPresented = false
    }

    func updateMessage(_ message: String) {
        self.message = String(message.prefix(maxMessageLength))
    }

    private func maskedAccountNo(_ raw: String) -> String {
        let suffix = raw.suffix(4)
        return "****-\(suffix)"
    }

    private func formattedCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "0"
        return "\(currency) \(formatted)"
    }

    private func buildValidationRequest(
        amount: Int,
        sourceOfFund: FundTransferPrimaryAccount
    ) -> FundTransferValidationRequest {
        let transferDate = ISO8601DateFormatter().string(from: Date())
        let amountCcy = sourceOfFund.accountCcy.isEmpty ? recipient.accountCurrency : sourceOfFund.accountCcy

        return FundTransferValidationRequest(
            responseCodeOTP: "",
            sourceAccount: .init(
                accountNo: sourceOfFund.accountNo,
                accountName: sourceOfFund.accountName,
                accountType: sourceOfFund.accountType,
                dynamicAccountId: sourceOfFund.dynamicAccountId,
                productCode: sourceOfFund.productCode,
                productName: sourceOfFund.productName,
                accountBalances: [
                    .init(
                        accountCcy: amountCcy,
                        balance: sourceOfFund.balance,
                        isAvailable: sourceOfFund.isAvailable
                    )
                ]
            ),
            listNonRegisteredAccount: [
                .init(
                    beneAccount: .init(
                        accountNo: recipient.accountNo,
                        accountName: recipient.displayName,
                        accountBalances: [.init(accountCcy: recipient.accountCurrency)],
                        bankCode: "",
                        bankName: recipient.bankName
                    ),
                    beneTransaction: .init(
                        transferServiceCode: "IFT",
                        amount: String(amount),
                        amountCcy: amountCcy,
                        interval: transactionIntervalCode,
                        recurStartDate: "",
                        recurEndDate: "",
                        remark: message,
                        transferDate: transferDate
                    )
                )
            ]
        )
    }

    private var transactionIntervalCode: String {
        switch selectedTransactionTime {
        case .now:
            return ""
        case .scheduled:
            return "S"
        case .recurring:
            return "W"
        }
    }
}
