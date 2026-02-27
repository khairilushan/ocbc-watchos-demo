import DesignSystem
import ImageIO
import SwiftUI

struct QrisCodeView: View {
    let payload: String

    var body: some View {
        qrImage
            .resizable()
            .interpolation(.none)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("QRIS code")
    }

    private var qrImage: Image {
        guard
            let data = Data(base64Encoded: payload),
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return Image.imageSampleQr
        }

        return Image(decorative: imageRef, scale: 1)
    }
}
