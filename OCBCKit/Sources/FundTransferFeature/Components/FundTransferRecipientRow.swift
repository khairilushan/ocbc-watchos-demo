import SwiftUI

struct FundTransferRecipientRow: View {
    let item: FundTransferRecipientItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.isFavorite ? "star.fill" : "person.fill")
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 28, height: 28)
                .foregroundStyle(.white)
                .background(.red.opacity(0.9), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(item.nickname.isEmpty ? item.accountName : item.nickname)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Text(item.bankName.isEmpty ? "Bank Transfer" : item.bankName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .foregroundStyle(.white)
        .clipShape(.capsule)
        .glassEffect(
            .regular.tint(.white.opacity(0.08)).interactive(),
            in: .capsule
        )
    }
}
