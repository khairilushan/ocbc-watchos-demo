import SwiftUI

struct WithdrawalResultView: View {
    let model: WithdrawalResultModel
    let doneButtonTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Text(model.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))

                Text("Amount: \(model.amountText)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)

                Text("Transaction ID: \(model.transactionId)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))

                Text("OTP: \(model.transactionOtp)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Token: \(model.tokenCard)")
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(2)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassEffect(
                .regular.tint(.white.opacity(0.08)).interactive(),
                in: .rect(cornerRadius: 12)
            )

            Button("Done", action: doneButtonTapped)
                .buttonStyle(.glassProminent)
        }
        .padding(.horizontal, 12)
    }
}
