import Networking

public struct InquiryBalanceTotalEndpoint: Endpoint {
    public typealias Response = InquiryBalanceTotalResponse

    public let path = "/dashboard/inquiry-balance-total"
    public let method: HTTPMethod = .get

    public init() {}
}
