import Networking

public struct GetFundTransferPrimaryAccountEndpoint: Endpoint {
    public typealias Response = GetFundTransferPrimaryAccountResponse

    public let path = "/fundtransfer/account/primary"
    public let method: HTTPMethod = .get

    public init() {}
}
