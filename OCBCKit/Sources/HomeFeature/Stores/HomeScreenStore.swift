import AppCore
import Observation

@MainActor
@Observable
final class HomeScreenStore {
    var state: ScreenState<[HomeMenuItem]> = .loading

    func task() async {
        do {
            try await Task.sleep(for: .seconds(0.8))
            state = .success(mapToUiModel(HomeMenuServiceModel.sample))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load home menu.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: [HomeMenuServiceModel]) -> [HomeMenuItem] {
        data.map {
            HomeMenuItem(
                id: $0.destination,
                title: $0.title,
                symbol: $0.symbol,
                destination: $0.destination,
                isMultiline: $0.isMultiline
            )
        }
    }
}

private struct HomeMenuServiceModel {
    let title: String
    let symbol: String
    let destination: Destination
    let isMultiline: Bool

    static let sample: [Self] = [
        .init(title: "Account Balance", symbol: "person.text.rectangle", destination: .balance, isMultiline: false),
        .init(title: "QRIS Pay", symbol: "qrcode.viewfinder", destination: .qris, isMultiline: false),
        .init(title: "Withdrawal", symbol: "banknote", destination: .withdrawal, isMultiline: false),
        .init(title: "Fund Transfer", symbol: "arrow.left.arrow.right", destination: .fundTransfer, isMultiline: false),
        .init(title: "Payment &\nPurchase", symbol: "creditcard", destination: .payment, isMultiline: true)
    ]
}
