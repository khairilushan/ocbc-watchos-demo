import SwiftUI

struct FundTransferRecipientSummaryCard: View {
    let recipientName: String
    let recipientBankName: String
    let recipientAccountText: String
    let sourceOfFundTitle: String
    let sourceOfFundAccountText: String
    let sourceOfFundBalanceText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recipient")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(recipientName)
                    .font(.system(size: 15, weight: .semibold))
                Text(recipientBankName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(recipientAccountText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 2) {
                Text("Source Funds")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(sourceOfFundTitle)
                    .font(.system(size: 14, weight: .semibold))
                Text(sourceOfFundAccountText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                if !sourceOfFundBalanceText.isEmpty {
                    Text(sourceOfFundBalanceText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .glassEffect(.regular.tint(.white.opacity(0.08)).interactive(), in: .rect(cornerRadius: 16))
    }
}
