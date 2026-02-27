import SwiftUI

struct WithdrawalAmountSheet: View {
    let options: [WithdrawalAmountOption]
    let onSelect: (WithdrawalAmountOption) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(options) { option in
            Button(option.value) {
                onSelect(option)
                dismiss()
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
    }
}
