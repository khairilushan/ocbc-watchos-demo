import SwiftUI

struct WithdrawalAmountPickerButton: View {
    let selectedAmountText: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(selectedAmountText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .clipShape(.capsule)
            .glassEffect(
                .regular.tint(.white.opacity(0.08)).interactive(),
                in: .capsule
            )
        }
        .buttonStyle(.plain)
    }
}
