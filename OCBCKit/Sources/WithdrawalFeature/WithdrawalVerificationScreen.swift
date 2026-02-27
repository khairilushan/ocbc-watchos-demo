import AppCore
import DesignSystem
import SwiftUI

public struct WithdrawalVerificationScreen: View {
    @State private var store = WithdrawalVerificationScreenStore()
    @Environment(\.router) private var router

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(model):
                WithdrawalResultView(model: model) {
                    router?.popToRoot()
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
