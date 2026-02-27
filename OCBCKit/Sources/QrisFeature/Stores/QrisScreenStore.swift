import AppCore
import Dependencies
import Observation
import QrisCore

@MainActor
@Observable
final class QrisScreenStore {
    @ObservationIgnored
    @Dependency(\.qrisClient)
    private var qrisClient

    var state: ScreenState<QrisPaymentModel> = .loading

    func task() async {
        do {
            let account = try await qrisClient.fetchPrimaryAccount()
            state = .success(mapToUiModel(account))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load QRIS data.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: QrisPrimaryAccount) -> QrisPaymentModel {
        QrisPaymentModel(payload: data.qrCodePayload)
    }
}
