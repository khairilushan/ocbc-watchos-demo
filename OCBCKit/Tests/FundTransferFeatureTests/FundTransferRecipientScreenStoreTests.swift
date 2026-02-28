import AppCore
import CasePaths
import Dependencies
import FundTransferCore
import Foundation
import Testing
@testable import FundTransferFeature

@MainActor
@Test
func recipientTask_whenRemoteSucceeds_setsRecipientListState() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
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
                .init(
                    recipients: [
                        .init(
                            id: "001",
                            accountNo: "masked",
                            accountName: "Steve Jobs",
                            accountFullname: "Steve Roberto Carlos Jobs",
                            nickname: "Jobs",
                            isFavorite: true,
                            bankId: "028",
                            swiftCode: "",
                            bankName: "OCBC NISP",
                            transferCategory: "IDR",
                            citizenshipCode: "RS001",
                            citizenshipValue: "WNI",
                            citizenshipDescription: ""
                        )
                    ],
                    pagination: .init(pageNumber: 1, pageSize: 10, totalData: 1)
                )
            }
        )
    } operation: {
        FundTransferRecipientScreenStore()
    }

    await store.task()

    guard let model = store.state[case: \.success] else {
        Issue.record("Expected success state")
        return
    }

    #expect(model.recipients.count == 1)
    #expect(model.recipients.first?.nickname == "Jobs")
    #expect(model.recipients.first?.accountNo == "masked")
}

@MainActor
@Test
func recipientTask_whenRemoteFails_setsFailureState() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
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
                throw RecipientMockError.failed
            }
        )
    } operation: {
        FundTransferRecipientScreenStore()
    }

    await store.task()

    guard let message = store.state[case: \.failure] else {
        Issue.record("Expected failure state")
        return
    }

    #expect(message == "Failed to load recipients.")
}

private enum RecipientMockError: Error {
    case failed
}

@MainActor
@Test
func recipientLoadMore_whenLastItemAppears_appendsNextPage() async throws {
    let store = withDependencies {
        $0.fundTransferClient = FundTransferClient(
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
            fetchRecipients: { _, _, pageNumber, _ in
                if pageNumber == 1 {
                    return .init(
                        recipients: [
                            .init(
                                id: "001",
                                accountNo: "masked-1",
                                accountName: "Steve Jobs",
                                accountFullname: "Steve Jobs",
                                nickname: "Jobs",
                                isFavorite: true,
                                bankId: "028",
                                swiftCode: "",
                                bankName: "OCBC NISP",
                                transferCategory: "IDR",
                                citizenshipCode: "RS001",
                                citizenshipValue: "WNI",
                                citizenshipDescription: ""
                            )
                        ],
                        pagination: .init(pageNumber: 1, pageSize: 10, totalData: 2)
                    )
                }
                return .init(
                    recipients: [
                        .init(
                            id: "002",
                            accountNo: "masked-2",
                            accountName: "Steve Wozniak",
                            accountFullname: "Steve Wozniak",
                            nickname: "Wozniak",
                            isFavorite: false,
                            bankId: "028",
                            swiftCode: "",
                            bankName: "OCBC NISP",
                            transferCategory: "IDR",
                            citizenshipCode: "RS001",
                            citizenshipValue: "WNI",
                            citizenshipDescription: ""
                        )
                    ],
                    pagination: .init(pageNumber: 2, pageSize: 10, totalData: 2)
                )
            }
        )
    } operation: {
        FundTransferRecipientScreenStore()
    }

    await store.task()
    let firstPageModel = try #require(store.state[case: \.success])
    let lastItem = try #require(firstPageModel.recipients.last)

    await store.loadMoreIfNeeded(currentItem: lastItem)

    let appendedModel = try #require(store.state[case: \.success])
    #expect(appendedModel.recipients.count == 2)
    #expect(appendedModel.recipients.last?.nickname == "Wozniak")
}
