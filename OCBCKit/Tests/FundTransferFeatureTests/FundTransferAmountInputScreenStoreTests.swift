import AppCore
import Dependencies
import FundTransferCore
import Testing
@testable import FundTransferFeature

@MainActor
@Test
func amountInputTask_whenSourceFundFetchSucceeds_setsSourceFundData() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
            fetchPrimaryAccount: {
                .init(
                    hasDefaultAccount: true,
                    productCode: "SAV",
                    productName: "IDR Savings",
                    accountNo: "1234567890",
                    accountType: "S",
                    accountName: "AULIA",
                    dynamicAccountId: "dyn",
                    qrCodePayload: "qr",
                    accountCcy: "IDR",
                    balance: 2500000,
                    isAvailable: true
                )
            }
        )
    } operation: {
        FundTransferAmountInputScreenStore(
            recipient: .init(
                id: "1",
                displayName: "John Doe",
                bankName: "OCBC",
                accountNo: "0987654321",
                accountCurrency: "IDR"
            )
        )
    }

    await store.task()

    #expect(store.sourceOfFundTitle == "IDR Savings")
    #expect(store.sourceOfFundAccountText == "****-7890 (IDR)")
    #expect(store.sourceOfFundBalanceText == "Balance IDR 2,500,000")
}

@MainActor
@Test
func amountInputTask_whenSourceFundFetchFails_showsUnavailableData() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
            fetchPrimaryAccount: {
                throw AmountInputStoreMockError.failed
            }
        )
    } operation: {
        FundTransferAmountInputScreenStore(
            recipient: .init(
                id: "1",
                displayName: "John Doe",
                bankName: "OCBC",
                accountNo: "0987654321",
                accountCurrency: "IDR"
            )
        )
    }

    await store.task()

    #expect(store.sourceOfFundTitle == "Source Funds")
    #expect(store.sourceOfFundAccountText == "Not available")
    #expect(store.sourceOfFundBalanceText.isEmpty)
}

private enum AmountInputStoreMockError: Error {
    case failed
}

@MainActor
@Test
func continueButtonTapped_whenValidationSucceeds_returnsPinDestination() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
            fetchPrimaryAccount: {
                .init(
                    hasDefaultAccount: true,
                    productCode: "SAV",
                    productName: "IDR Savings",
                    accountNo: "1234567890",
                    accountType: "S",
                    accountName: "AULIA",
                    dynamicAccountId: "dyn",
                    qrCodePayload: "qr",
                    accountCcy: "IDR",
                    balance: 2500000,
                    isAvailable: true
                )
            },
            validateTransfer: { _ in
                .init(
                    warningCode: "COT01",
                    transactionId: "txn-123",
                    transferServiceCode: "IFT",
                    onlineSessionId: "online-123",
                    warningMessage: "Warning message"
                )
            }
        )
    } operation: {
        FundTransferAmountInputScreenStore(
            recipient: .init(
                id: "1",
                displayName: "John Doe",
                bankName: "OCBC",
                accountNo: "0987654321",
                accountCurrency: "IDR"
            )
        )
    }

    await store.task()
    store.amountSelected(125000)
    store.updateMessage("test")

    let destination = await store.continueButtonTapped()

    #expect(store.continueErrorMessage == nil)
    #expect(store.isSubmitting == false)
    guard case let .pin(appliNumber, sequenceNumber, next) = destination else {
        Issue.record("Expected pin destination")
        return
    }
    #expect(appliNumber == "online-123")
    #expect(sequenceNumber == "0")
    #expect(next == .home)
}

@MainActor
@Test
func continueButtonTapped_whenValidationFails_setsErrorMessage() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
            fetchPrimaryAccount: {
                .init(
                    hasDefaultAccount: true,
                    productCode: "SAV",
                    productName: "IDR Savings",
                    accountNo: "1234567890",
                    accountType: "S",
                    accountName: "AULIA",
                    dynamicAccountId: "dyn",
                    qrCodePayload: "qr",
                    accountCcy: "IDR",
                    balance: 2500000,
                    isAvailable: true
                )
            },
            validateTransfer: { _ in
                throw AmountInputStoreMockError.failed
            }
        )
    } operation: {
        FundTransferAmountInputScreenStore(
            recipient: .init(
                id: "1",
                displayName: "John Doe",
                bankName: "OCBC",
                accountNo: "0987654321",
                accountCurrency: "IDR"
            )
        )
    }

    await store.task()
    store.amountSelected(125000)

    let destination = await store.continueButtonTapped()

    #expect(store.continueErrorMessage == "Failed to validate transfer.")
    #expect(store.isSubmitting == false)
    #expect(destination == nil)
}
