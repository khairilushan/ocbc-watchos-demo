import SwiftUI

struct FundTransferRecipientListView: View {
    let items: [FundTransferRecipientItem]
    let isLoadingMore: Bool
    let recipientTapped: (FundTransferRecipientItem) -> Void
    let itemAppeared: (FundTransferRecipientItem) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    Button {
                        recipientTapped(item)
                    } label: {
                        FundTransferRecipientRow(item: item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(item.accountName), \(item.bankName)")
                    .onAppear {
                        itemAppeared(item)
                    }
                }

                if isLoadingMore {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
