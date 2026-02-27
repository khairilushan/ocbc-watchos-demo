import AppCore
import Dependencies
import Networking

public struct QrisClient: Sendable {
    public var fetchPrimaryAccount: @Sendable () async throws -> QrisPrimaryAccount

    public init(fetchPrimaryAccount: @escaping @Sendable () async throws -> QrisPrimaryAccount) {
        self.fetchPrimaryAccount = fetchPrimaryAccount
    }
}

public extension QrisClient {
    static func live(apiClient: APIClient) -> Self {
        Self {
            let response = try await apiClient.execute(GetQrisPrimaryAccountEndpoint())
            return QrisPrimaryAccount(qrCodePayload: response.data.account.qrCode)
        }
    }

    static func demo() -> Self {
        .live(apiClient: PreviewNetworkingValues.apiClient())
    }
}

private enum QrisClientKey: DependencyKey {
    static var liveValue: QrisClient {
        .demo()
    }

    static var previewValue: QrisClient {
        .init {
            .init(qrCodePayload: "")
        }
    }

    static var testValue: QrisClient {
        .init {
            .init(qrCodePayload: "")
        }
    }
}

public extension DependencyValues {
    var qrisClient: QrisClient {
        get { self[QrisClientKey.self] }
        set { self[QrisClientKey.self] = newValue }
    }
}
