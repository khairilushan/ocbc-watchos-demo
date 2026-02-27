import AppCore
import Dependencies
import Networking

public struct BalanceClient: Sendable {
    public var fetchTotalBalances: @Sendable () async throws -> [BalanceCurrencyAccount]

    public init(fetchTotalBalances: @escaping @Sendable () async throws -> [BalanceCurrencyAccount]) {
        self.fetchTotalBalances = fetchTotalBalances
    }
}

public extension BalanceClient {
    static func live(apiClient: APIClient) -> Self {
        Self {
            let response = try await apiClient.execute(InquiryBalanceTotalEndpoint())
            return response.data.listAccountBalanceByCIF.map {
                BalanceCurrencyAccount(
                    currencyCode: $0.accountCcy,
                    accountCcyNameID: $0.accountCcyNameID,
                    accountCcyNameEN: $0.accountCcyNameEN,
                    balance: $0.balance,
                    isAvailable: $0.isAvailable,
                    iconURL: $0.iconURL
                )
            }
        }
    }

    static func demo() -> Self {
        .live(apiClient: PreviewNetworkingValues.apiClient())
    }
}

private enum BalanceClientKey: DependencyKey {
    static var liveValue: BalanceClient {
        .demo()
    }

    static var previewValue: BalanceClient {
        .init {
            []
        }
    }

    static var testValue: BalanceClient {
        .init {
            []
        }
    }
}

public extension DependencyValues {
    var balanceClient: BalanceClient {
        get { self[BalanceClientKey.self] }
        set { self[BalanceClientKey.self] = newValue }
    }
}
