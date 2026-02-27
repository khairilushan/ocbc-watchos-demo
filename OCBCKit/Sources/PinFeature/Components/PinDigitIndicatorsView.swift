import SwiftUI

struct PinDigitIndicatorsView: View {
    let enteredDigits: Int
    let maxDigits: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<maxDigits, id: \.self) { index in
                Circle()
                    .fill(index < enteredDigits ? .white : .white.opacity(0.2))
                    .frame(width: 10, height: 10)
            }
        }
    }
}
