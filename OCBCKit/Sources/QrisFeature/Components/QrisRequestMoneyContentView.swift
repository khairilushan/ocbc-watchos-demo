import SwiftUI

struct QrisRequestMoneyContentView: View {
    let model: QrisPaymentModel

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 6
            let cardWidth = proxy.size.width - (horizontalPadding * 2)

            ScrollView {
                VStack(spacing: 8) {
                    QrisCardView(model: model, cardWidth: cardWidth)

                    if let selectedAmountText = model.selectedAmountText {
                        Text(selectedAmountText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, horizontalPadding)
            }
            .scrollIndicators(.hidden)
        }
    }
}
