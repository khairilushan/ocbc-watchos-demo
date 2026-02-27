import AppCore
import BalanceCore
import CasePaths
import Dependencies
import Testing
@testable import BalanceFeature

@MainActor
@Test
func task_whenRemoteSucceeds_setsSuccessStateWithMappedAccounts() async throws {
    let store = withDependencies {
        $0.balanceClient = BalanceClient {
            [
                BalanceCurrencyAccount(
                    currencyCode: "IDR",
                    accountCcyNameID: "IDR ID",
                    accountCcyNameEN: "IDR EN",
                    balance: 1497382669.02,
                    isAvailable: true,
                    iconURL: "https://example.com/idr.png"
                ),
                BalanceCurrencyAccount(
                    currencyCode: "USD",
                    accountCcyNameID: "USD ID",
                    accountCcyNameEN: "USD EN",
                    balance: 1957483.55,
                    isAvailable: true,
                    iconURL: "https://example.com/usd.png"
                )
            ]
        }
    } operation: {
        BalanceScreenStore()
    }

    await store.task()

    guard let accounts = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(accounts.count == 2)
    #expect(accounts[0].id == "idr")
    #expect(accounts[0].flag == "🇮🇩")
    #expect(accounts[0].currency == "IDR")
    #expect(accounts[0].amount == "1,497,382,669.02")

    #expect(accounts[1].id == "usd")
    #expect(accounts[1].flag == "🇺🇸")
    #expect(accounts[1].currency == "USD")
    #expect(accounts[1].amount == "1,957,483.55")
}

@MainActor
@Test
func task_whenRemoteFails_setsFailureState() async throws {
    let store = withDependencies {
        $0.balanceClient = BalanceClient {
            throw MockError.failed
        }
    } operation: {
        BalanceScreenStore()
    }

    await store.task()

    guard let message = store.state[case: \.failure] else {
        Issue.record("Expected failure state")
        return
    }

    #expect(message == "Failed to load balances.")
}

private enum MockError: Error {
    case failed
}
