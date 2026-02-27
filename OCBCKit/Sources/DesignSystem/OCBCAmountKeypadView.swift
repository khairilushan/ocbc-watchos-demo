import Foundation
import SwiftUI

public struct OCBCAmountKeypadView: View {
    @State private var amountInput = ""

    private let confirmTitle: String
    private let onConfirm: (Int?) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    private let keypadValues = [
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        "0", "00", "000"
    ]

    public init(confirmTitle: String = "Continue", onConfirm: @escaping (Int?) -> Void) {
        self.confirmTitle = confirmTitle
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack {
            Text(displayAmount)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(10)
                .glassEffect()

            ScrollView {
                VStack(spacing: 8) {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(keypadValues, id: \.self) { value in
                            Button(value) {
                                append(value)
                            }
                            .buttonStyle(.glass)
                        }
                    }
                }
                .padding(10)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(confirmTitle) {
                    onConfirm(normalizedAmount)
                }
            }
        }
    }

    private var normalizedAmount: Int? {
        let raw = amountInput.filter(\.isNumber)
        return Int(raw)
    }

    private var displayAmount: String {
        guard let amount = normalizedAmount else { return "IDR 0" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "IDR \(formatted)"
    }

    private func append(_ value: String) {
        let next = amountInput + value
        if next.count <= 12 {
            amountInput = next
        }
    }
}
