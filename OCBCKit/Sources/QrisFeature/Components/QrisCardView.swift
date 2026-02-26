import SwiftUI

struct QrisCardView: View {
    let model: QrisPaymentModel

    var body: some View {
        VStack(spacing: 10) {
            QrisLogoView()
            QrisCodeView(payload: model.payload)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 176, height: 206)
        .background(.white, in: .rect(cornerRadius: 16))
    }
}
