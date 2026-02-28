import SwiftUI

public struct OCBCFailureView: View {
    private let message: String
    private let onRetry: () -> Void

    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.red)

            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Button("Retry", action: onRetry)
                .tint(Color.red.opacity(0.9))
                .buttonStyle(.glassProminent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

#Preview {
    OCBCFailureView(message: "Failed to load data.") {}
        .frame(width: 198, height: 242)
}
