import SwiftUI

public struct PinInputScreen: View {
    @Binding private var pin: String
    private let isSubmitting: Bool
    private let maxDigits: Int
    private let backButtonTapped: () -> Void
    private let pinCompleted: () -> Void
    @State private var lastSubmittedPin = ""

    private let keypadKeys: [PinKeyboardKey] = [
        .digit("1"), .digit("2"), .digit("3"),
        .digit("4"), .digit("5"), .digit("6"),
        .digit("7"), .digit("8"), .digit("9"),
        .empty, .digit("0"), .delete
    ]

    public init(
        pin: Binding<String>,
        isSubmitting: Bool,
        maxDigits: Int = 6,
        backButtonTapped: @escaping () -> Void,
        pinCompleted: @escaping () -> Void
    ) {
        _pin = pin
        self.isSubmitting = isSubmitting
        self.maxDigits = maxDigits
        self.backButtonTapped = backButtonTapped
        self.pinCompleted = pinCompleted
    }

    public var body: some View {
        VStack(spacing: 12) {
            PinDigitIndicatorsView(enteredDigits: pin.count, maxDigits: maxDigits)

            PinKeyboardGridView(
                keys: keypadKeys,
                digitTapped: appendDigit,
                deleteTapped: removeLastDigit
            )

            Button("Back") {
                backButtonTapped()
            }
            .buttonStyle(.bordered)
            .disabled(isSubmitting)
        }
        .padding(.horizontal, 12)
        .onChange(of: pin) { _, newValue in
            if newValue.count < maxDigits {
                lastSubmittedPin = ""
            }
            submitIfNeeded(for: newValue)
        }
    }

    private func appendDigit(_ digit: String) {
        guard pin.count < maxDigits else { return }
        pin.append(digit)
    }

    private func removeLastDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
    }

    private func submitIfNeeded(for pinValue: String) {
        guard pinValue.count == maxDigits else { return }
        guard pinValue != lastSubmittedPin else { return }
        guard !isSubmitting else { return }
        lastSubmittedPin = pinValue
        pinCompleted()
    }
}
