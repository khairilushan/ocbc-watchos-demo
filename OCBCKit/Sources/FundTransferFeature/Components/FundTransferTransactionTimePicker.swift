import SwiftUI

struct FundTransferTransactionTimePicker: View {
    let selected: FundTransferTransactionTimeOption
    let selectedChanged: (FundTransferTransactionTimeOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transaction Time")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(FundTransferTransactionTimeOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            selectedChanged(option)
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .foregroundStyle(selected == option ? .white : .primary)
                        .background(
                            selected == option
                                ? Color.red.opacity(0.9)
                                : Color.clear,
                            in: Capsule()
                        )
                        .overlay {
                            Capsule()
                                .strokeBorder(.white.opacity(selected == option ? 0 : 0.25), lineWidth: 1)
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
            .scrollIndicators(.hidden)
        }
        .padding(12)
        .glassEffect(.regular.tint(.white.opacity(0.08)), in: .rect(cornerRadius: 16))
    }
}
