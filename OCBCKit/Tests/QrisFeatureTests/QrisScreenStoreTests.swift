import AppCore
import CasePaths
import Dependencies
import QrisCore
import Testing
@testable import QrisFeature

@MainActor
@Test
func task_whenRemoteSucceeds_setsSuccessStateWithMappedPayload() async throws {
    let store = withDependencies {
        $0.qrisClient = QrisClient(
            fetchPrimaryAccount: {
                .init(qrCodePayload: "payload-123", dynamicAccountID: "dynamic-id")
            },
            generateQris: { request in
                #expect(request.amount == nil)
                return .init(encodedQRCode: "generated-initial", minimumAmount: 0, maximumAmount: 0)
            }
        )
    } operation: {
        QRISRequestMoneyScreenStore()
    }

    await store.task()

    guard let model = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(model.payload == "generated-initial")
    #expect(model.selectedAmountText == nil)
}

@MainActor
@Test
func task_whenRemoteFails_setsFailureState() async throws {
    let store = withDependencies {
        $0.qrisClient = QrisClient(
            fetchPrimaryAccount: {
                throw MockError.failed
            },
            generateQris: { _ in
                .init(encodedQRCode: "", minimumAmount: 0, maximumAmount: 0)
            }
        )
    } operation: {
        QRISRequestMoneyScreenStore()
    }

    await store.task()

    guard let message = store.state[case: \.failure] else {
        Issue.record("Expected failure state")
        return
    }

    #expect(message == "Failed to load QRIS data.")
}

@MainActor
@Test
func generateQRCode_whenAmountProvided_generatesWithAmount() async throws {
    let recorder = AmountRecorder()
    let store = withDependencies {
        $0.qrisClient = QrisClient(
            fetchPrimaryAccount: {
                .init(qrCodePayload: "payload-123", dynamicAccountID: "dynamic-id")
            },
            generateQris: { request in
                await recorder.record(request.amount)
                #expect(request.dynamicAccountID == "dynamic-id")
                return .init(encodedQRCode: "generated-payload", minimumAmount: 10000, maximumAmount: 2500000)
            }
        )
    } operation: {
        QRISRequestMoneyScreenStore()
    }

    await store.task()
    await store.generateQRCode(with: 58000)

    guard let model = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(model.payload == "generated-payload")
    #expect(model.selectedAmountText == "IDR 58,000")
    #expect(await recorder.lastAmount() == 58000)
}

private enum MockError: Error {
    case failed
}

private actor AmountRecorder {
    private var amounts: [Int?] = []

    func record(_ amount: Int?) {
        amounts.append(amount)
    }

    func lastAmount() -> Int? {
        amounts.last ?? nil
    }
}
