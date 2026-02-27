import AppCore
import DesignSystem
import PinFeature
import SwiftUI

public struct WithdrawalScreen: View {
    @State private var store = WithdrawalScreenStore()
    @Environment(\.router) private var router

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(model):
                content(model)
            case let .failure(message):
                OCBCFailureView(message: message) {
                    Task { await store.retryButtonTapped() }
                }
            }
        }
        .sheet(isPresented: $store.isAmountSheetPresented) {
            if let model = store.state[case: \.success] {
                WithdrawalAmountSheet(options: model.amountOptions) { option in
                    store.amountSelected(option)
                }
            }
        }
        .task {
            guard case .loading = store.state else { return }
            await store.task()
        }
    }

    @ViewBuilder
    private func content(_ model: WithdrawalInputModel) -> some View {
        switch store.flowStep {
        case .input:
            WithdrawalSelectionView(
                model: model,
                isSubmitting: store.isSubmitting,
                amountButtonTapped: { store.amountButtonTapped() },
                confirmButtonTapped: { Task { await store.confirmButtonTapped() } }
            )
        case .pin:
            PinInputScreen(
                pin: $store.pin,
                isSubmitting: store.isSubmitting,
                backButtonTapped: { store.backToInputButtonTapped() },
                pinCompleted: { Task { await store.pinConfirmButtonTapped() } }
            )
        case let .result(resultModel):
            WithdrawalResultView(model: resultModel) {
                store.backToInputButtonTapped()
                router?.popToRoot()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WithdrawalScreen()
    }
}
