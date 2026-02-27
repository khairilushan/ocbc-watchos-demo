import Foundation
import Networking

public struct GetWithdrawalAmountEndpoint: Endpoint {
    public typealias Response = GetWithdrawalAmountResponse

    public let path = "/parameter/withdrawal-amount"
    public let method: HTTPMethod = .post
    public let body: Data?
    public let headers: [String: String]

    public init(withdrawalType: WithdrawalType) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(RequestBody(withdrawalType: withdrawalType.rawValue))
    }
}

private struct RequestBody: Encodable {
    let withdrawalType: String
}
