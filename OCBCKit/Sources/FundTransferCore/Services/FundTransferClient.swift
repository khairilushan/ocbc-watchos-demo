import AppCore
import Dependencies
import Networking

public struct FundTransferClient: Sendable {
    public var fetchPrimaryAccount: @Sendable () async throws -> FundTransferPrimaryAccount

    public init(fetchPrimaryAccount: @escaping @Sendable () async throws -> FundTransferPrimaryAccount) {
        self.fetchPrimaryAccount = fetchPrimaryAccount
    }
}

public extension FundTransferClient {
    static func live(apiClient: APIClient) -> Self {
        Self {
            let response = try await apiClient.execute(GetFundTransferPrimaryAccountEndpoint())
            let account = response.data.account
            let balance = account.accountBalances.first

            return FundTransferPrimaryAccount(
                hasDefaultAccount: response.data.hasDefaultAccount,
                productCode: account.productCode,
                productName: account.productName,
                accountNo: account.accountNo,
                accountType: account.accountType,
                accountName: account.accountName,
                dynamicAccountId: account.dynamicAccountId,
                qrCodePayload: account.qrCode,
                accountCcy: balance?.accountCcy ?? "",
                balance: balance?.balance ?? 0,
                isAvailable: balance?.isAvailable ?? false
            )
        }
    }

    static func demo() -> Self {
        .live(apiClient: PreviewNetworkingValues.apiClient())
    }
}

private enum FundTransferClientKey: DependencyKey {
    static var liveValue: FundTransferClient {
        .demo()
    }

    static var previewValue: FundTransferClient {
        .init {
            .init(
                hasDefaultAccount: false,
                productCode: "",
                productName: "",
                accountNo: "",
                accountType: "",
                accountName: "",
                dynamicAccountId: "",
                qrCodePayload: "",
                accountCcy: "",
                balance: 0,
                isAvailable: false
            )
        }
    }

    static var testValue: FundTransferClient {
        .init {
            .init(
                hasDefaultAccount: false,
                productCode: "",
                productName: "",
                accountNo: "",
                accountType: "",
                accountName: "",
                dynamicAccountId: "",
                qrCodePayload: "",
                accountCcy: "",
                balance: 0,
                isAvailable: false
            )
        }
    }
}

public extension DependencyValues {
    var fundTransferClient: FundTransferClient {
        get { self[FundTransferClientKey.self] }
        set { self[FundTransferClientKey.self] = newValue }
    }
}
