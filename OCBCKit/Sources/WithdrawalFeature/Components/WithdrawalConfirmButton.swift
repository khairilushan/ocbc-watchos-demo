import SwiftUI

struct WithdrawalConfirmButton: View {
    let isLoading: Bool
    let isDisabled: Bool
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
        }
        .tint(Color.red.opacity(0.9))
        .buttonStyle(.glassProminent)
        .disabled(isDisabled || isLoading)
    }
}
