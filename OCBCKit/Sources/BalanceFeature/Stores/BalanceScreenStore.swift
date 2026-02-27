import AppCore
import BalanceCore
import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class BalanceScreenStore {
    @ObservationIgnored
    @Dependency(\.balanceClient)
    private var balanceClient

    var state: ScreenState<[BalanceAccount]> = .loading

    func task() async {
        do {
            let accounts = try await balanceClient.fetchTotalBalances()
            state = .success(mapToUiModel(accounts))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load balances.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: [BalanceCurrencyAccount]) -> [BalanceAccount] {
        data.map {
            BalanceAccount(
                id: $0.currencyCode.lowercased(),
                flag: Self.flag(for: $0.currencyCode),
                currency: $0.currencyCode,
                amount: Self.formatted(balance: $0.balance)
            )
        }
    }

    private static func formatted(balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
    }

    private static func flag(for currencyCode: String) -> String {
        switch currencyCode {
        case "IDR": return "🇮🇩"
        case "USD": return "🇺🇸"
        case "SGD": return "🇸🇬"
        case "JPY": return "🇯🇵"
        case "EUR": return "🇪🇺"
        case "AUD": return "🇦🇺"
        case "HKD": return "🇭🇰"
        case "GBP": return "🇬🇧"
        case "CAD": return "🇨🇦"
        case "CHF": return "🇨🇭"
        case "NZD": return "🇳🇿"
        case "CNH": return "🇨🇳"
        default: return "🏦"
        }
    }
}
