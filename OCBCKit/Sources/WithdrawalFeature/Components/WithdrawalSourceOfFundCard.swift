import SwiftUI

struct WithdrawalSourceOfFundCard: View {
    let sourceOfFund: WithdrawalSourceOfFundUiModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sourceOfFund.productName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            Text(sourceOfFund.accountNo)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))

            Text("\(sourceOfFund.accountCurrency) - \(sourceOfFund.balanceText)")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassEffect(
            .regular.tint(.white.opacity(0.08)).interactive(),
            in: .rect(cornerRadius: 12)
        )
    }
}
