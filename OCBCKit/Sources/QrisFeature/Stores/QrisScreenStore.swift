import AppCore
import Observation

@MainActor
@Observable
final class QrisScreenStore {
    var state: ScreenState<QrisPaymentModel> = .loading

    func task() async {
        do {
            try await Task.sleep(for: .seconds(1.6))
            state = .success(mapToUiModel(QrisServiceModel.sample))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load QRIS data.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: QrisServiceModel) -> QrisPaymentModel {
        QrisPaymentModel(payload: data.payload)
    }
}

private struct QrisServiceModel {
    let payload: String

    static let sample = Self(
        payload: "00020101021226670016COM.NOBUBANK.WWW01189360050300000879140214448252781008240303UKE51440014ID.CO.QRIS.WWW0215ID20253994993040303UKE5204581253033605405100005802ID5918TOKO CONTOH QRIS6007JAKARTA6105123406304A13B"
    )
}
