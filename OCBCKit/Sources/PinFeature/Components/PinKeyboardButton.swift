import SwiftUI

struct PinKeyboardButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 18, weight: .semibold))
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
