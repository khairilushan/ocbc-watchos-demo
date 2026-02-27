import AppCore
import Dependencies
import Networking

public struct QrisClient: Sendable {
    public var fetchPrimaryAccount: @Sendable () async throws -> QrisPrimaryAccount
    public var generateQris: @Sendable (GenerateQrisRequest) async throws -> GeneratedQris

    public init(
        fetchPrimaryAccount: @escaping @Sendable () async throws -> QrisPrimaryAccount,
        generateQris: @escaping @Sendable (GenerateQrisRequest) async throws -> GeneratedQris
    ) {
        self.fetchPrimaryAccount = fetchPrimaryAccount
        self.generateQris = generateQris
    }
}

public extension QrisClient {
    static func live(apiClient: APIClient) -> Self {
        Self(
            fetchPrimaryAccount: {
                let response = try await apiClient.execute(GetQrisPrimaryAccountEndpoint())
                return QrisPrimaryAccount(
                    qrCodePayload: response.data.account.qrCode,
                    dynamicAccountID: response.data.account.dynamicAccountId
                )
            },
            generateQris: { request in
                let response = try await apiClient.execute(PostGenerateQrisEndpoint(request: request))
                return GeneratedQris(
                    encodedQRCode: response.data.encodedQRCode,
                    minimumAmount: response.data.minimumAmount,
                    maximumAmount: response.data.maximumAmount
                )
            }
        )
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
        .init(
            fetchPrimaryAccount: {
                .init(qrCodePayload: "", dynamicAccountID: "")
            },
            generateQris: { _ in
                .init(encodedQRCode: "", minimumAmount: 0, maximumAmount: 0)
            }
        )
    }

    static var testValue: QrisClient {
        previewValue
    }
}

public extension DependencyValues {
    var qrisClient: QrisClient {
        get { self[QrisClientKey.self] }
        set { self[QrisClientKey.self] = newValue }
    }
}
