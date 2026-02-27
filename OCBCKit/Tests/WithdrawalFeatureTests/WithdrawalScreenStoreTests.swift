import AppCore
import CasePaths
import Dependencies
import Testing
import WithdrawalCore
@testable import WithdrawalFeature

@MainActor
@Test
func task_whenRemoteSucceeds_setsInputStepAndDefaultAmount() async throws {
    let store = withDependencies {
        $0.withdrawalClient = .init(
            fetchAmountConfiguration: { _ in
                .init(
                    parameters: [
                        .init(code: "100000", value: "IDR 100,000"),
                        .init(code: "200000", value: "IDR 200,000")
                    ],
                    minimumAmount: 100000,
                    maximumAmount: 2500000,
                    denominationAmount: 100000
                )
            },
            fetchSourceOfFunds: {
                [
                    .init(
                        productCode: "TBSMCY9902",
                        productName: "Tanda360Plus-Digital",
                        accountNo: "693810029464",
                        accountType: "S",
                        accountCcy: "IDR",
                        balance: 999558224.26,
                        isAvailable: true
                    )
                ]
            },
            validate: { _ in
                .init(
                    withdrawalType: "OTP",
                    remitterPhoneNumber: "remitter",
                    benePhoneNumber: "bene",
                    pin: "enc-pin",
                    amountCode: "100000",
                    amountValue: "IDR 100,000",
                    sourceOfFundAccountNo: "693810029464",
                    onlineSessionId: "session-id"
                )
            },
            verifyPinOTP: { _ in
                .init(responseCode: "00000", responseDescriptionEN: "SUCCESS", responseDescriptionID: "SUKSES")
            },
            acknowledge: { _ in
                .init(
                    responseCode: "00000",
                    responseDescription: "SUCCESS",
                    amountCode: "100000",
                    amountValue: "IDR 100,000",
                    transactionId: "tx-id",
                    transactionOTP: "827382",
                    tokenCard: "token",
                    messageTitle: "Done",
                    messageSubtitle: "Use token in ATM"
                )
            },
            generateToken: { _ in
                .init(
                    responseCode: "00000",
                    responseDescription: "SUCCESS",
                    amountCode: "100000",
                    amountValue: "IDR 100,000",
                    transactionId: "tx-id",
                    transactionOTP: "827382",
                    tokenCard: "token",
                    messageTitle: "Done",
                    messageSubtitle: "Use token in ATM"
                )
            }
        )
    } operation: {
        WithdrawalScreenStore()
    }

    await store.task()

    guard let model = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(store.flowStep == .input)
    #expect(model.amountOptions.count == 2)
    #expect(model.selectedAmount.code == "100000")
    #expect(model.sourceOfFund.productName == "Tanda360Plus-Digital")
}

@MainActor
@Test
func confirmAndPinValidation_movesToResultStep() async throws {
    let store = withDependencies {
        $0.withdrawalClient = .init(
            fetchAmountConfiguration: { _ in
                .init(
                    parameters: [.init(code: "100000", value: "IDR 100,000")],
                    minimumAmount: 100000,
                    maximumAmount: 2500000,
                    denominationAmount: 100000
                )
            },
            fetchSourceOfFunds: {
                [
                    .init(
                        productCode: "TBSMCY9902",
                        productName: "Tanda360Plus-Digital",
                        accountNo: "693810029464",
                        accountType: "S",
                        accountCcy: "IDR",
                        balance: 999558224.26,
                        isAvailable: true
                    )
                ]
            },
            validate: { _ in
                .init(
                    withdrawalType: "OTP",
                    remitterPhoneNumber: "remitter",
                    benePhoneNumber: "bene",
                    pin: "enc-pin",
                    amountCode: "100000",
                    amountValue: "IDR 100,000",
                    sourceOfFundAccountNo: "693810029464",
                    onlineSessionId: "session-id"
                )
            },
            verifyPinOTP: { request in
                #expect(request.otpCode == "123456")
                return .init(responseCode: "00000", responseDescriptionEN: "SUCCESS", responseDescriptionID: "SUKSES")
            },
            acknowledge: { request in
                #expect(request.onlineSessionID == "session-id")
                return .init(
                    responseCode: "00000",
                    responseDescription: "SUCCESS",
                    amountCode: "100000",
                    amountValue: "IDR 100,000",
                    transactionId: "tx-id",
                    transactionOTP: "827382",
                    tokenCard: "token",
                    messageTitle: "Done",
                    messageSubtitle: "Use token in ATM"
                )
            },
            generateToken: { _ in
                .init(
                    responseCode: "00000",
                    responseDescription: "SUCCESS",
                    amountCode: "100000",
                    amountValue: "IDR 100,000",
                    transactionId: "tx-id",
                    transactionOTP: "827382",
                    tokenCard: "token",
                    messageTitle: "Done",
                    messageSubtitle: "Use token in ATM"
                )
            }
        )
    } operation: {
        WithdrawalScreenStore()
    }

    await store.task()
    await store.confirmButtonTapped()

    #expect(store.flowStep == .pin)

    store.pin = "123456"
    await store.pinConfirmButtonTapped()

    guard case let .result(result) = store.flowStep else {
        Issue.record("Expected result flow step")
        return
    }

    #expect(result.transactionId == "tx-id")
    #expect(result.transactionOtp == "827382")
}
