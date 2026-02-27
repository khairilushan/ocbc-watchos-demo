import SwiftUI

struct PinDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "delete.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .clipShape(.capsule)
                .glassEffect(
                    .regular.tint(.white.opacity(0.08)).interactive(),
                    in: .capsule
                )
        }
        .buttonStyle(.plain)
    }
}
