import AppCore
import DesignSystem
import SwiftUI

public struct FundTransferRecipientScreen: View {
    @State private var store = FundTransferRecipientScreenStore()
    @Environment(\.router) private var router

    public init() {}

    public var body: some View {
        Group {
            switch store.state {
            case .loading:
                OCBCLoadingView()
            case let .success(model):
                FundTransferRecipientListView(
                    items: model.recipients,
                    isLoadingMore: store.isLoadingMore,
                    recipientTapped: { item in
                        router?.route(
                            to: .fundTransferAmountInput(
                                .init(
                                    id: item.id,
                                    displayName: item.nickname.isEmpty ? item.accountName : item.nickname,
                                    bankName: item.bankName,
                                    accountNo: item.accountNo,
                                    accountCurrency: item.accountCurrency
                                )
                            )
                        )
                    },
                    itemAppeared: { item in
                        Task { await store.loadMoreIfNeeded(currentItem: item) }
                    }
                )
            case let .failure(message):
                OCBCFailureView(message: message) {
                    Task { await store.retryButtonTapped() }
                }
            }
        }
        .task {
            guard case .loading = store.state else { return }
            await store.task()
        }
    }
}
