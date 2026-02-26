import SwiftUI

struct HomeMenuRowContent: View {
    let item: HomeMenuItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.symbol)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 28, height: 28)
                .foregroundStyle(.white)
                .background(.red.opacity(0.9), in: Circle())

            Text(item.title)
                .font(item.isMultiline ? .system(size: 14, weight: .semibold) : .system(size: 15, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .frame(height: item.isMultiline ? 46 : 40)
        .foregroundStyle(.white)
        .clipShape(.capsule)
        .glassEffect(
            .regular.tint(.white.opacity(0.08)).interactive(),
            in: .capsule
        )
    }
}
