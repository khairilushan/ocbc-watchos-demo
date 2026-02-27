import AppCore
import Dependencies
import Networking

public struct WithdrawalClient: Sendable {
    public var fetchAmountConfiguration: @Sendable (WithdrawalType) async throws -> WithdrawalAmountConfiguration
    public var fetchSourceOfFunds: @Sendable () async throws -> [WithdrawalSourceOfFundAccount]
    public var validate: @Sendable (WithdrawalValidationRequest) async throws -> WithdrawalValidationResult
    public var verifyPinOTP: @Sendable (VerifyPinOTPRequest) async throws -> VerifyPinOTPResult
    public var acknowledge: @Sendable (WithdrawalAckRequest) async throws -> WithdrawalAckResult
    public var generateToken: @Sendable (WithdrawalAckRequest) async throws -> WithdrawalAckResult

    public init(
        fetchAmountConfiguration: @escaping @Sendable (WithdrawalType) async throws -> WithdrawalAmountConfiguration,
        fetchSourceOfFunds: @escaping @Sendable () async throws -> [WithdrawalSourceOfFundAccount],
        validate: @escaping @Sendable (WithdrawalValidationRequest) async throws -> WithdrawalValidationResult,
        verifyPinOTP: @escaping @Sendable (VerifyPinOTPRequest) async throws -> VerifyPinOTPResult,
        acknowledge: @escaping @Sendable (WithdrawalAckRequest) async throws -> WithdrawalAckResult,
        generateToken: @escaping @Sendable (WithdrawalAckRequest) async throws -> WithdrawalAckResult
    ) {
        self.fetchAmountConfiguration = fetchAmountConfiguration
        self.fetchSourceOfFunds = fetchSourceOfFunds
        self.validate = validate
        self.verifyPinOTP = verifyPinOTP
        self.acknowledge = acknowledge
        self.generateToken = generateToken
    }
}

public extension WithdrawalClient {
    static func live(apiClient: APIClient) -> Self {
        Self(
            fetchAmountConfiguration: { withdrawalType in
                let response = try await apiClient.execute(GetWithdrawalAmountEndpoint(withdrawalType: withdrawalType))
                return WithdrawalAmountConfiguration(
                    parameters: response.data.parameters.map {
                        WithdrawalAmountParameter(code: $0.code, value: $0.value)
                    },
                    minimumAmount: response.data.minimumAmount,
                    maximumAmount: response.data.maximumAmount,
                    denominationAmount: response.data.denominationAmount
                )
            },
            fetchSourceOfFunds: {
                let response = try await apiClient.execute(GetWithdrawalSourceOfFundsEndpoint())
                return response.data.accounts.compactMap { account in
                    guard let balance = account.accountBalances.first else { return nil }
                    return WithdrawalSourceOfFundAccount(
                        productCode: account.productCode,
                        productName: account.productName,
                        accountNo: account.accountNo,
                        accountType: account.accountType,
                        accountCcy: balance.accountCcy,
                        balance: balance.balance,
                        isAvailable: balance.isAvailable
                    )
                }
            },
            validate: { request in
                let response = try await apiClient.execute(PostWithdrawalValidationEndpoint(request: request))
                return WithdrawalValidationResult(
                    withdrawalType: response.data.withdrawalType,
                    remitterPhoneNumber: response.data.remitterPhoneNumber,
                    benePhoneNumber: response.data.benePhoneNumber,
                    pin: response.data.pin,
                    amountCode: response.data.amount.code,
                    amountValue: response.data.amount.value,
                    sourceOfFundAccountNo: response.data.sourceOfFund.accountNo,
                    onlineSessionId: response.data.onlineSessionId
                )
            },
            verifyPinOTP: { request in
                let response = try await apiClient.execute(PostVerifyPinOTPEndpoint(request: request))
                return VerifyPinOTPResult(
                    responseCode: response.responseCode,
                    responseDescriptionEN: response.responseDescriptionEN,
                    responseDescriptionID: response.responseDescriptionID
                )
            },
            acknowledge: { request in
                let response = try await apiClient.execute(PostWithdrawalAckEndpoint(request: request))
                return WithdrawalAckResult(
                    responseCode: response.responseCode,
                    responseDescription: response.responseDescription,
                    amountCode: response.data.amount.code,
                    amountValue: response.data.amount.value,
                    transactionId: response.data.transactionId,
                    transactionOTP: response.data.transactionOTP,
                    tokenCard: response.data.tokenCard,
                    messageTitle: response.data.message.title,
                    messageSubtitle: response.data.message.subtitle
                )
            },
            generateToken: { request in
                let response = try await apiClient.execute(PostWithdrawalAckEndpoint(request: request))
                return WithdrawalAckResult(
                    responseCode: response.responseCode,
                    responseDescription: response.responseDescription,
                    amountCode: response.data.amount.code,
                    amountValue: response.data.amount.value,
                    transactionId: response.data.transactionId,
                    transactionOTP: response.data.transactionOTP,
                    tokenCard: response.data.tokenCard,
                    messageTitle: response.data.message.title,
                    messageSubtitle: response.data.message.subtitle
                )
            }
        )
    }

    static func demo() -> Self {
        .live(apiClient: PreviewNetworkingValues.apiClient())
    }
}

private enum WithdrawalClientKey: DependencyKey {
    static var liveValue: WithdrawalClient {
        .demo()
    }

    static var previewValue: WithdrawalClient {
        .init(
            fetchAmountConfiguration: { _ in
                .init(parameters: [], minimumAmount: 0, maximumAmount: 0, denominationAmount: 0)
            },
            fetchSourceOfFunds: {
                []
            },
            validate: { _ in
                .init(
                    withdrawalType: "",
                    remitterPhoneNumber: "",
                    benePhoneNumber: "",
                    pin: "",
                    amountCode: "",
                    amountValue: "",
                    sourceOfFundAccountNo: "",
                    onlineSessionId: ""
                )
            },
            verifyPinOTP: { _ in
                .init(responseCode: "", responseDescriptionEN: "", responseDescriptionID: "")
            },
            acknowledge: { _ in
                .init(
                    responseCode: "",
                    responseDescription: "",
                    amountCode: "",
                    amountValue: "",
                    transactionId: "",
                    transactionOTP: "",
                    tokenCard: "",
                    messageTitle: "",
                    messageSubtitle: ""
                )
            },
            generateToken: { _ in
                .init(
                    responseCode: "",
                    responseDescription: "",
                    amountCode: "",
                    amountValue: "",
                    transactionId: "",
                    transactionOTP: "",
                    tokenCard: "",
                    messageTitle: "",
                    messageSubtitle: ""
                )
            }
        )
    }

    static var testValue: WithdrawalClient {
        previewValue
    }
}

public extension DependencyValues {
    var withdrawalClient: WithdrawalClient {
        get { self[WithdrawalClientKey.self] }
        set { self[WithdrawalClientKey.self] = newValue }
    }
}
