import Networking

public struct GetWithdrawalSourceOfFundsEndpoint: Endpoint {
    public typealias Response = GetWithdrawalSourceOfFundsResponse

    public let path = "/card/withdrawal/source-of-funds"
    public let method: HTTPMethod = .get

    public init() {}
}
