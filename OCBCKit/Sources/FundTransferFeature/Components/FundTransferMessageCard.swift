import SwiftUI

struct FundTransferMessageCard: View {
    @Binding var message: String
    let countText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Message (Optional)")
                .font(.system(size: 13, weight: .semibold))

            TextField("Input your message here", text: $message)

            HStack {
                Spacer()
                Text(countText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .glassEffect(.regular.tint(.white.opacity(0.08)), in: .rect(cornerRadius: 16))
    }
}
