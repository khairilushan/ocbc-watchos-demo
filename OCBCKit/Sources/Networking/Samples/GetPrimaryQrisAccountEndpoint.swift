import Foundation

public struct GetPrimaryQrisAccountEndpoint: Endpoint {
    public struct Response: Decodable, Sendable, Equatable {
        public var accountID: String
        public var accountName: String

        public init(accountID: String, accountName: String) {
            self.accountID = accountID
            self.accountName = accountName
        }
    }

    public let path = "/qris/account/primary"
    public let method: HTTPMethod = .get

    public init() {}
}
