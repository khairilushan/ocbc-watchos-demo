import SwiftUI

public struct FundTransferView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 30, weight: .semibold))
            Text("Fund Transfer")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.black)
        .foregroundStyle(.white)
    }
}
