import AppCore
import CasePaths
import Dependencies
import FundTransferCore
import Testing
@testable import FundTransferFeature

@MainActor
@Test
func task_whenRemoteSucceeds_setsSuccessStateWithMappedTitle() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient {
            .init(
                hasDefaultAccount: true,
                productCode: "P",
                productName: "Prod",
                accountNo: "123",
                accountType: "S",
                accountName: "AULIA RACHMAN",
                dynamicAccountId: "id",
                qrCodePayload: "qr",
                accountCcy: "IDR",
                balance: 1,
                isAvailable: true
            )
        }
    } operation: {
        FundTransferScreenStore()
    }

    await store.task()

    guard let model = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(model.symbol == "arrow.left.arrow.right")
    #expect(model.title == "AULIA RACHMAN")
}

@MainActor
@Test
func task_whenRemoteFails_setsFailureState() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient {
            throw MockError.failed
        }
    } operation: {
        FundTransferScreenStore()
    }

    await store.task()

    guard let message = store.state[case: \.failure] else {
        Issue.record("Expected failure state")
        return
    }

    #expect(message == "Failed to load fund transfer.")
}

private enum MockError: Error {
    case failed
}
