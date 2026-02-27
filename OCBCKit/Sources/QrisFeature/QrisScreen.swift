import DesignSystem
import SwiftUI

public struct QRISRequestMoneyScreen: View {
    @State private var store = QRISRequestMoneyScreenStore()
    @State private var isCustomAmountSheetPresented = false

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(model):
                QrisRequestMoneyContentView(model: model)
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
        .toolbar {
            #if os(watchOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Amount") {
                        isCustomAmountSheetPresented = true
                    }
                }
            #endif
        }
        .sheet(isPresented: $isCustomAmountSheetPresented) {
            OCBCAmountKeypadView(confirmTitle: "Generate QR") { amount in
                isCustomAmountSheetPresented = false
                Task { await store.generateQRCode(with: amount) }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QRISRequestMoneyScreen()
    }
}
