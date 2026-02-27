import Foundation
import Networking

public struct PostWithdrawalValidationEndpoint: Endpoint {
    public typealias Response = PostWithdrawalValidationResponse

    public let path = "/card/withdrawal/validation"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: WithdrawalValidationRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
