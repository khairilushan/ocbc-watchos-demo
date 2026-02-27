import AppCore
import Dependencies
import Foundation
import Observation
import QrisCore

@MainActor
@Observable
final class QRISRequestMoneyScreenStore {
    @ObservationIgnored
    @Dependency(\.qrisClient)
    private var qrisClient

    var state: ScreenState<QrisPaymentModel> = .loading

    private var dynamicAccountID: String?

    func task() async {
        do {
            let account = try await qrisClient.fetchPrimaryAccount()
            dynamicAccountID = account.dynamicAccountID
            await generateQRCode(with: nil)
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load QRIS data.")
        }
    }

    func generateQRCode(with amount: Int?) async {
        guard let dynamicAccountID else {
            state = .failure("Failed to load QRIS data.")
            return
        }

        state = .loading

        do {
            let request = GenerateQrisRequest(
                amount: amount,
                dynamicAccountID: dynamicAccountID,
                remark: ""
            )
            let generated = try await qrisClient.generateQris(request)
            state = .success(
                QrisPaymentModel(
                    payload: generated.encodedQRCode,
                    selectedAmountText: amountText(for: amount)
                )
            )
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to generate QRIS code.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func amountText(for amount: Int?) -> String? {
        guard let amount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "IDR \(formatted)"
    }
}
