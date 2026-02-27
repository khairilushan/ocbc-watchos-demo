import SwiftUI

struct QrisCustomAmountSheetView: View {
    @State private var amountInput = ""

    let onGenerate: (Int?) -> Void

    var body: some View {
        VStack(spacing: 10) {
            amountField
            Button("Generate QR") {
                onGenerate(normalizedAmount)
            }
            .buttonStyle(.glassProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(10)
    }

    private var amountField: some View {
        TextField("Amount", text: $amountInput)
            .padding(12)
            .glassEffect()
    }

    private var normalizedAmount: Int? {
        let raw = amountInput.filter(\.isNumber)
        return Int(raw)
    }
}
