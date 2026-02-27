import SwiftUI

struct WithdrawalSelectionView: View {
    let model: WithdrawalInputModel
    let isSubmitting: Bool
    let amountButtonTapped: () -> Void
    let confirmButtonTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            WithdrawalSourceOfFundCard(sourceOfFund: model.sourceOfFund)
            WithdrawalAmountPickerButton(
                selectedAmountText: model.selectedAmount.value,
                onTap: amountButtonTapped
            )
            WithdrawalConfirmButton(
                isLoading: isSubmitting,
                isDisabled: false,
                title: "Confirm",
                action: confirmButtonTapped
            )
        }
        .padding(.horizontal, 12)
    }
}
