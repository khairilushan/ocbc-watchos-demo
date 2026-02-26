import DesignSystem
import SwiftUI

public struct BalanceScreen: View {
    @State private var store = BalanceScreenStore()

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(accounts):
                BalanceAccountsListView(accounts: accounts)
            case let .failure(message):
                OCBCFailureView(message: message) {
                    Task { await store.retryButtonTapped() }
                }
            }
        }
        .task {
            guard case .loading = store.state else { return }
            await store.task()
        }
    }
}

#Preview {
    NavigationStack {
        BalanceScreen()
    }
}
