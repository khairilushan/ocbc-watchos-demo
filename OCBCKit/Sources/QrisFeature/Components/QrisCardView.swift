import SwiftUI

struct QrisCardView: View {
    let model: QrisPaymentModel

    var body: some View {
        if let payload = model.payload {
            VStack(spacing: 4) {
                QrisLogoView()
                QrisCodeView(payload: payload)
                    .border(.red)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white, in: .rect(cornerRadius: 16))
        }
    }
}
