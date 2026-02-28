import AppCore
import Dependencies
import Networking

public struct FundTransferClient: Sendable {
    public var fetchPrimaryAccount: @Sendable () async throws -> FundTransferPrimaryAccount
    public var fetchRecipients: @Sendable (
        _ category: String,
        _ keyword: String,
        _ pageNumber: Int,
        _ pageSize: Int
    ) async throws -> FundTransferRecipientList
    public var validateTransfer: @Sendable (FundTransferValidationRequest) async throws -> FundTransferValidationResult

    public init(
        fetchPrimaryAccount: @escaping @Sendable () async throws -> FundTransferPrimaryAccount,
        fetchRecipients: @escaping @Sendable (
            _ category: String,
            _ keyword: String,
            _ pageNumber: Int,
            _ pageSize: Int
        ) async throws -> FundTransferRecipientList = { _, _, _, _ in
            .init(recipients: [], pagination: .init(pageNumber: 1, pageSize: 10, totalData: 0))
        },
        validateTransfer: @escaping @Sendable (FundTransferValidationRequest) async throws -> FundTransferValidationResult = { _ in
            .init(
                warningCode: "",
                transactionId: "",
                transferServiceCode: "",
                onlineSessionId: "",
                warningMessage: ""
            )
        }
    ) {
        self.fetchPrimaryAccount = fetchPrimaryAccount
        self.fetchRecipients = fetchRecipients
        self.validateTransfer = validateTransfer
    }
}

public extension FundTransferClient {
    static func live(apiClient: APIClient) -> Self {
        Self(
            fetchPrimaryAccount: {
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
            },
            fetchRecipients: { category, keyword, pageNumber, pageSize in
                let request = FundTransferRecipientSearchRequest(
                    category: category,
                    keyword: keyword,
                    pagination: .init(pageNumber: pageNumber, pageSize: pageSize)
                )
                let response = try await apiClient.execute(PostFundTransferRecipientsEndpoint(request: request))
                return FundTransferRecipientList(
                    recipients: response.data.recipients.map {
                        FundTransferRecipient(
                            id: $0.id,
                            accountNo: $0.accountNo,
                            accountName: $0.accountName,
                            accountFullname: $0.accountFullname,
                            nickname: $0.nickname,
                            isFavorite: $0.isFavorite,
                            bankId: $0.bank.bankId,
                            swiftCode: $0.bank.swiftCode,
                            bankName: $0.bank.bankName,
                            transferCategory: $0.transferCategory,
                            citizenshipCode: $0.citizenship.code,
                            citizenshipValue: $0.citizenship.value,
                            citizenshipDescription: $0.citizenship.description
                        )
                    },
                    pagination: .init(
                        pageNumber: response.data.pagination.pageNumber,
                        pageSize: response.data.pagination.pageSize,
                        totalData: response.data.pagination.totalData
                    )
                )
            },
            validateTransfer: { request in
                let response = try await apiClient.execute(PostFundTransferValidationEndpoint(request: request))
                let item = response.data.listNonRegisteredAccount.first
                return FundTransferValidationResult(
                    warningCode: response.data.warningCode ?? "",
                    transactionId: item?.beneTransaction.id ?? "",
                    transferServiceCode: item?.beneTransaction.transferServiceCode ?? "",
                    onlineSessionId: item?.beneTransaction.onlineSessionId ?? "",
                    warningMessage: item?.beneTransaction.warningMessage ?? ""
                )
            }
        )
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
        .init(
            fetchPrimaryAccount: {
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
            },
            fetchRecipients: { _, _, _, _ in
                .init(recipients: [], pagination: .init(pageNumber: 1, pageSize: 10, totalData: 0))
            },
            validateTransfer: { _ in
                .init(
                    warningCode: "",
                    transactionId: "",
                    transferServiceCode: "",
                    onlineSessionId: "",
                    warningMessage: ""
                )
            }
        )
    }

    static var testValue: FundTransferClient {
        .init(
            fetchPrimaryAccount: {
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
            },
            fetchRecipients: { _, _, _, _ in
                .init(recipients: [], pagination: .init(pageNumber: 1, pageSize: 10, totalData: 0))
            },
            validateTransfer: { _ in
                .init(
                    warningCode: "",
                    transactionId: "",
                    transferServiceCode: "",
                    onlineSessionId: "",
                    warningMessage: ""
                )
            }
        )
    }
}

public extension DependencyValues {
    var fundTransferClient: FundTransferClient {
        get { self[FundTransferClientKey.self] }
        set { self[FundTransferClientKey.self] = newValue }
    }
}
