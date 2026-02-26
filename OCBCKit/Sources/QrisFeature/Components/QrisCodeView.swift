import DesignSystem
import SwiftUI

struct QrisCodeView: View {
    let payload: String

    var body: some View {
        Image.imageSampleQr
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 138, height: 138)
            .accessibilityLabel("QRIS code")
    }
}
