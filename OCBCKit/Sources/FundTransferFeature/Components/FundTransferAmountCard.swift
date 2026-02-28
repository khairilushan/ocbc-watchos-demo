import SwiftUI

struct FundTransferAmountCard: View {
    let amountText: String
    let amountTapped: () -> Void

    var body: some View {
        Button {
            amountTapped()
        } label: {
            HStack {
                Text("Amount")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(amountText)
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .contentShape(Rectangle())
            .glassEffect(.regular.tint(.white.opacity(0.08)).interactive(), in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
