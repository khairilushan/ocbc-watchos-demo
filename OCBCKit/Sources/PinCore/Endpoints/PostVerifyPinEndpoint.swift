import Foundation
import Networking

public struct PostVerifyPinEndpoint: Endpoint {
    public typealias Response = PostVerifyPinResponse

    public let path = "/token/v3/verify/pin/otp"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: VerifyPinRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
