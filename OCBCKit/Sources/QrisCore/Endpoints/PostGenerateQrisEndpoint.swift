import Foundation
import Networking

public struct PostGenerateQrisEndpoint: Endpoint {
    public typealias Response = PostGenerateQrisResponse

    public let path = "/qris/generate-qris"
    public let method: HTTPMethod = .post
    public let headers: [String: String]
    public let body: Data?

    public init(request: GenerateQrisRequest) {
        self.headers = ["Content-Type": "application/json"]
        self.body = try? JSONEncoder().encode(request)
    }
}
