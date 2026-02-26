import DesignSystem
import SwiftUI

struct QrisLogoView: View {
    var body: some View {
        Image.iconQrisLogo
            .resizable()
            .scaledToFit()
            .frame(width: 58, height: 18)
            .accessibilityHidden(true)
    }
}
