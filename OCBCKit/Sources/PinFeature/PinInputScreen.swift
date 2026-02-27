import AppCore
import PinCore
import SwiftUI

public struct PinInputScreen: View {
    @State private var store: PinInputScreenStore
    private let nextDestination: Destination
    @Environment(\.router) private var router

    private let keypadKeys: [PinKeyboardKey] = [
        .digit("1"), .digit("2"), .digit("3"),
        .digit("4"), .digit("5"), .digit("6"),
        .digit("7"), .digit("8"), .digit("9"),
        .empty, .digit("0"), .delete
    ]

    public init(
        appliNumber: String,
        sequenceNumber: String = "0",
        maxDigits: Int = 6,
        nextDestination: Destination
    ) {
        self.nextDestination = nextDestination
        _store = State(
            initialValue: PinInputScreenStore(
                appliNumber: appliNumber,
                sequenceNumber: sequenceNumber,
                maxDigits: maxDigits
            )
        )
    }

    public var body: some View {
        VStack(spacing: 12) {
            PinDigitIndicatorsView(enteredDigits: store.pin.count, maxDigits: store.maxDigits)

            PinKeyboardGridView(
                keys: keypadKeys,
                digitTapped: store.appendDigit,
                deleteTapped: store.removeLastDigit
            )
            .disabled(store.isSubmitting)
            .opacity(store.isSubmitting ? 0.45 : 1)
            .overlay {
                if store.isSubmitting {
                    ProgressView("Verifying...")
                        .controlSize(.small)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: Capsule())
                }
            }
            .overlay(alignment: .bottom) {
                if let errorMessage = store.errorMessage, !store.isSubmitting {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: Capsule())
                        .padding(.bottom, 4)
                }
            }
        }
        .padding(.horizontal, 12)
        .onChange(of: store.isVerified) { _, isVerified in
            guard isVerified else { return }
            router?.replaceTop(with: nextDestination)
        }
    }
}
