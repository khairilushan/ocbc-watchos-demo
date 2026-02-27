import Networking

public struct GetQrisPrimaryAccountEndpoint: Endpoint {
    public typealias Response = GetQrisPrimaryAccountResponse

    public let path = "/qris/account/primary"
    public let method: HTTPMethod = .get

    public init() {}
}
