import Foundation

public protocol NonceGenerator: Sendable {
    func makeNonce() -> String
}

public struct RandomNonceGenerator: NonceGenerator {
    public init() {}

    public func makeNonce() -> String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
