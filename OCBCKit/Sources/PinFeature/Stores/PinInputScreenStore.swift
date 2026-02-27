import Dependencies
import Observation
import PinCore

@MainActor
@Observable
final class PinInputScreenStore {
    @ObservationIgnored
    @Dependency(\.pinVerificationClient)
    private var pinVerificationClient

    private let appliNumber: String
    private let sequenceNumber: String

    let maxDigits: Int
    var pin = ""
    var isSubmitting = false
    var errorMessage: String?
    var isVerified = false

    private var lastSubmittedPin = ""

    init(
        appliNumber: String,
        sequenceNumber: String,
        maxDigits: Int
    ) {
        self.appliNumber = appliNumber
        self.sequenceNumber = sequenceNumber
        self.maxDigits = maxDigits
    }

    func appendDigit(_ digit: String) {
        guard !isSubmitting else { return }
        guard pin.count < maxDigits else { return }
        pin.append(digit)
        errorMessage = nil
        if pin.count < maxDigits {
            lastSubmittedPin = ""
        }
        submitIfNeeded()
    }

    func removeLastDigit() {
        guard !isSubmitting else { return }
        guard !pin.isEmpty else { return }
        pin.removeLast()
        errorMessage = nil
        if pin.count < maxDigits {
            lastSubmittedPin = ""
        }
    }

    private func submitIfNeeded() {
        guard pin.count == maxDigits else { return }
        guard pin != lastSubmittedPin else { return }
        guard !isSubmitting else { return }

        let currentPin = pin
        lastSubmittedPin = currentPin

        Task {
            isSubmitting = true
            defer { isSubmitting = false }

            do {
                let result = try await pinVerificationClient.verify(
                    .init(
                        appliNumber: appliNumber,
                        otpCode: currentPin,
                        sequenceNumber: sequenceNumber
                    )
                )
                guard result.responseCode == "00000" else {
                    pin = ""
                    lastSubmittedPin = ""
                    errorMessage = "Failed to verify PIN."
                    return
                }
                await PinVerificationSession.shared.setVerifiedPin(currentPin, for: appliNumber)
                isVerified = true
            } catch is CancellationError {
            } catch {
                pin = ""
                lastSubmittedPin = ""
                errorMessage = "Failed to verify PIN."
            }
        }
    }
}
