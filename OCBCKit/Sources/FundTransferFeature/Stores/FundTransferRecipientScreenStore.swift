import AppCore
import Dependencies
import FundTransferCore
import Observation

@MainActor
@Observable
final class FundTransferRecipientScreenStore {
    @ObservationIgnored
    @Dependency(\.fundTransferClient)
    private var fundTransferClient

    var state: ScreenState<FundTransferRecipientScreenModel> = .loading
    var isLoadingMore = false

    private let pageSize = 10
    private var currentPage = 0
    private var totalData = 0

    func task() async {
        currentPage = 0
        totalData = 0
        isLoadingMore = false

        do {
            let result = try await fundTransferClient.fetchRecipients("IDR", "", 1, pageSize)
            let items = mapRecipients(result.recipients)
            currentPage = result.pagination.pageNumber
            totalData = result.pagination.totalData
            state = .success(.init(recipients: items))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load recipients.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    func loadMoreIfNeeded(currentItem: FundTransferRecipientItem) async {
        guard !isLoadingMore else { return }
        guard let model = state[case: \.success] else { return }
        guard shouldLoadMore(currentItem: currentItem, items: model.recipients) else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let result = try await fundTransferClient.fetchRecipients("IDR", "", nextPage, pageSize)
            let newItems = mapRecipients(result.recipients)
            let updatedRecipients = model.recipients + newItems
            state = .success(.init(recipients: updatedRecipients))
            currentPage = result.pagination.pageNumber
            totalData = max(totalData, result.pagination.totalData)
        } catch is CancellationError {
        } catch {
        }
    }

    private func shouldLoadMore(
        currentItem: FundTransferRecipientItem,
        items: [FundTransferRecipientItem]
    ) -> Bool {
        guard items.last?.id == currentItem.id else { return false }
        return items.count < totalData
    }

    private func mapRecipients(_ recipients: [FundTransferRecipient]) -> [FundTransferRecipientItem] {
        recipients.map {
            FundTransferRecipientItem(
                id: $0.id,
                accountName: $0.accountName,
                nickname: $0.nickname,
                bankName: $0.bankName,
                accountNo: $0.accountNo,
                accountCurrency: $0.transferCategory,
                isFavorite: $0.isFavorite
            )
        }
    }
}
