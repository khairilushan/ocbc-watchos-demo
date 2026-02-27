import SwiftUI

struct QrisRequestMoneyContentView: View {
    let model: QrisPaymentModel

    var body: some View {
        VStack(spacing: 8) {
            QrisCardView(model: model)

            if let selectedAmountText = model.selectedAmountText {
                Text(selectedAmountText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 10)
    }
}
