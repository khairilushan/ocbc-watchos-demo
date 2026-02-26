import AppCore
import Observation

@MainActor
@Observable
final class BalanceScreenStore {
    var state: ScreenState<[BalanceAccount]> = .loading

    func task() async {
        do {
            try await Task.sleep(for: .seconds(1.2))
            state = .success(mapToUiModel(BalanceAccountServiceModel.sample))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load balances.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: [BalanceAccountServiceModel]) -> [BalanceAccount] {
        data.map {
            BalanceAccount(
                id: $0.id,
                flag: $0.flag,
                currency: $0.currency,
                amount: $0.amount
            )
        }
    }
}

private struct BalanceAccountServiceModel {
    let id: String
    let flag: String
    let currency: String
    let amount: String

    static let sample: [Self] = [
        .init(id: "idr", flag: "🇮🇩", currency: "IDR", amount: "1,497,382,669.02"),
        .init(id: "usd", flag: "🇺🇸", currency: "USD", amount: "1,957,483.55"),
        .init(id: "sgd", flag: "🇸🇬", currency: "SGD", amount: "1,046,737.69"),
        .init(id: "eur", flag: "🇪🇺", currency: "EUR", amount: "884,251.44"),
        .init(id: "jpy", flag: "🇯🇵", currency: "JPY", amount: "22,140,983.00"),
        .init(id: "gbp", flag: "🇬🇧", currency: "GBP", amount: "713,902.18"),
        .init(id: "aud", flag: "🇦🇺", currency: "AUD", amount: "1,102,645.70")
    ]
}
