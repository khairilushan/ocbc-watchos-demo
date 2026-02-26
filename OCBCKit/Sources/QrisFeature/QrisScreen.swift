import DesignSystem
import SwiftUI

public struct QrisScreen: View {
    @State private var store = QrisScreenStore()

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(model):
                QrisCardView(model: model)
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
        QrisScreen()
    }
}
