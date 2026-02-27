import AppCore
import Dependencies
import Networking

public struct PinVerificationClient: Sendable {
    public var verify: @Sendable (VerifyPinRequest) async throws -> PinVerificationResult

    public init(verify: @escaping @Sendable (VerifyPinRequest) async throws -> PinVerificationResult) {
        self.verify = verify
    }
}

public extension PinVerificationClient {
    static func live(apiClient: APIClient) -> Self {
        .init { request in
            let response = try await apiClient.execute(PostVerifyPinEndpoint(request: request))
            return PinVerificationResult(
                responseCode: response.responseCode,
                responseDescriptionEN: response.responseDescriptionEN,
                responseDescriptionID: response.responseDescriptionID
            )
        }
    }

    static func demo() -> Self {
        .live(apiClient: PreviewNetworkingValues.apiClient())
    }
}

private enum PinVerificationClientKey: DependencyKey {
    static var liveValue: PinVerificationClient { .demo() }

    static var previewValue: PinVerificationClient {
        .init { _ in
            .init(responseCode: "00000", responseDescriptionEN: "SUCCESS", responseDescriptionID: "SUKSES")
        }
    }

    static var testValue: PinVerificationClient { previewValue }
}

public extension DependencyValues {
    var pinVerificationClient: PinVerificationClient {
        get { self[PinVerificationClientKey.self] }
        set { self[PinVerificationClientKey.self] = newValue }
    }
}
