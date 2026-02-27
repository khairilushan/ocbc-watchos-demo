import DesignSystem
import SwiftUI

struct QrisLogoView: View {
    var body: some View {
        Image.iconQrisLogo
            .resizable()
            .scaledToFit()
            .frame(height: 14)
            .accessibilityHidden(true)
    }
}
