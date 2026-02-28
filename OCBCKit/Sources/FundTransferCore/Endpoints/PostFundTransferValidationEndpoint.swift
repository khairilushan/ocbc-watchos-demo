import Foundation
import Networking

public struct PostFundTransferValidationEndpoint: Endpoint {
    public typealias Response = PostFundTransferValidationResponse

    public let path = "/fundtransfer/v5/validate"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: FundTransferValidationRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
