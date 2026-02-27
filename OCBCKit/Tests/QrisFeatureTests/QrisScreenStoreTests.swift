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
        $0.qrisClient = QrisClient {
            .init(qrCodePayload: "payload-123")
        }
    } operation: {
        QrisScreenStore()
    }

    await store.task()

    guard let model = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(model.payload == "payload-123")
}

@MainActor
@Test
func task_whenRemoteFails_setsFailureState() async throws {
    let store = withDependencies {
        $0.qrisClient = QrisClient {
            throw MockError.failed
        }
    } operation: {
        QrisScreenStore()
    }

    await store.task()

    guard let message = store.state[case: \.failure] else {
        Issue.record("Expected failure state")
        return
    }

    #expect(message == "Failed to load QRIS data.")
}

private enum MockError: Error {
    case failed
}
