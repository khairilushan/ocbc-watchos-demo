import SwiftUI

struct QrisCardView: View {
    let model: QrisPaymentModel
    let cardWidth: CGFloat

    var body: some View {
        if let payload = model.payload {
            let contentPadding: CGFloat = 2
            let qrSize = cardWidth - (contentPadding * 2)

            VStack(spacing: 2) {
                QrisLogoView()
                QrisCodeView(payload: payload)
                    .frame(width: qrSize, height: qrSize)
            }
            .padding(contentPadding)
            .frame(width: cardWidth)
            .background(.white, in: .rect(cornerRadius: 16))
            .clipShape(.rect(cornerRadius: 16))
        }
    }
}
