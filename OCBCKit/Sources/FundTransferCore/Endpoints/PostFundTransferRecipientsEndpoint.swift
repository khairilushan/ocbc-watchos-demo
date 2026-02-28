import Foundation
import Networking

public struct PostFundTransferRecipientsEndpoint: Endpoint {
    public typealias Response = PostFundTransferRecipientsResponse

    public let path = "/recipient/v5/transfer"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: FundTransferRecipientSearchRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
