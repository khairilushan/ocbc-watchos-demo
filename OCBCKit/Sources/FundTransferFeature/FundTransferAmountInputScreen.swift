import AppCore
import DesignSystem
import SwiftUI

public struct FundTransferAmountInputScreen: View {
    @Environment(\.router) private var router
    @State private var store: FundTransferAmountInputScreenStore

    public init(recipient: FundTransferRecipientContext) {
        _store = State(initialValue: FundTransferAmountInputScreenStore(recipient: recipient))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                FundTransferRecipientSummaryCard(
                    recipientName: store.recipientDisplayName,
                    recipientBankName: store.recipientSecondaryText,
                    recipientAccountText: store.recipientAccountText,
                    sourceOfFundTitle: store.sourceOfFundTitle,
                    sourceOfFundAccountText: store.sourceOfFundAccountText,
                    sourceOfFundBalanceText: store.sourceOfFundBalanceText
                )

                FundTransferAmountCard(
                    amountText: store.formattedAmount,
                    amountTapped: store.amountButtonTapped
                )

                FundTransferMessageCard(
                    message: Binding(
                        get: { store.message },
                        set: { store.updateMessage($0) }
                    ),
                    countText: store.messageCountText
                )

                FundTransferTransactionTimePicker(
                    selected: store.selectedTransactionTime,
                    selectedChanged: { store.selectedTransactionTime = $0 }
                )

                Button("Continue") {
                    Task {
                        guard let destination = await store.continueButtonTapped() else { return }
                        router?.route(to: destination)
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(.white)
                .background(
                    Color.red.opacity(0.9),
                    in: .rect(cornerRadius: 12)
                )
                .opacity((!store.canContinue || store.isSubmitting) ? 0.45 : 1)
                .disabled(!store.canContinue || store.isSubmitting)
            }
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $store.isAmountKeypadPresented) {
            OCBCAmountKeypadView(confirmTitle: "Set Amount") { amount in
                store.amountSelected(amount)
            }
        }
        .task {
            await store.task()
        }
        .alert("Fund Transfer", isPresented: Binding(
            get: { store.continueErrorMessage != nil },
            set: { show in
                if !show {
                    store.continueErrorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.continueErrorMessage ?? "")
        }
    }
}
