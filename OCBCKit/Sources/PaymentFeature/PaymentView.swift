import DesignSystem
import SwiftUI

public struct PaymentView: View {
    @State private var store = PaymentScreenStore()

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(model):
                VStack(spacing: 10) {
                    Image(systemName: model.symbol)
                        .font(.system(size: 30, weight: .semibold))
                    Text(model.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            case let .failure(message):
                OCBCFailureView(message: message) {
                    Task { await store.retryButtonTapped() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            guard case .loading = store.state else { return }
            await store.task()
        }
        .padding()
        .background(.black)
        .foregroundStyle(.white)
    }
}
