import AppCore
import Observation

@MainActor
@Observable
final class PaymentScreenStore {
    var state: ScreenState<PaymentUiModel> = .loading

    func task() async {
        do {
            try await Task.sleep(for: .seconds(1.0))
            state = .success(mapToUiModel(PaymentServiceModel.sample))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load payment feature.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: PaymentServiceModel) -> PaymentUiModel {
        PaymentUiModel(symbol: data.icon, title: data.title)
    }
}

struct PaymentUiModel {
    let symbol: String
    let title: String
}

private struct PaymentServiceModel {
    let icon: String
    let title: String

    static let sample = Self(icon: "creditcard", title: "Payment & Purchase")
}
