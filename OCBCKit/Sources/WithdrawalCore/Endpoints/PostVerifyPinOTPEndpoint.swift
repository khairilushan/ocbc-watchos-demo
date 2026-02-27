import Foundation
import Networking

public struct PostVerifyPinOTPEndpoint: Endpoint {
    public typealias Response = PostVerifyPinOTPResponse

    public let path = "/token/v3/verify/pin/otp"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: VerifyPinOTPRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
