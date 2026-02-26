import SwiftUI

public struct PaymentView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "creditcard")
                .font(.system(size: 30, weight: .semibold))
            Text("Payment & Purchase")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.black)
        .foregroundStyle(.white)
    }
}
