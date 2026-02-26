import AppCore
import DesignSystem
import SwiftUI

public struct HomeScreen: View {
    @State private var store = HomeScreenStore()
    @Environment(\.router) private var router

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(items):
                HomeMenuListView(items: items) { destination in
                    router?.route(to: destination)
                }
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
        HomeScreen()
            .environment(\.router, Router())
    }
}
