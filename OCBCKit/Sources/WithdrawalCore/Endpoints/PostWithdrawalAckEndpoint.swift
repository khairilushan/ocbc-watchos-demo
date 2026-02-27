import Foundation
import Networking

public struct PostWithdrawalAckEndpoint: Endpoint {
    public typealias Response = PostWithdrawalAckResponse

    public let path = "/card/withdrawal/ack"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: WithdrawalAckRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
