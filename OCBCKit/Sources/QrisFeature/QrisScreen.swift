import DesignSystem
import SwiftUI

public struct QrisScreen: View {
    private let simulateLoading: Bool
    @State private var isLoading: Bool

    public init(simulateLoading: Bool = true) {
        self.simulateLoading = simulateLoading
        _isLoading = State(initialValue: simulateLoading)
    }

    public var body: some View {
        Group {
            if isLoading {
                OCBCLoadingView()
                    .transition(.opacity)
            } else {
                QrisCardView(model: .sample)
                    .transition(.opacity)
            }
        }
        .task {
            guard simulateLoading, isLoading else { return }
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.easeInOut(duration: 0.25)) {
                isLoading = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        QrisScreen()
    }
}
