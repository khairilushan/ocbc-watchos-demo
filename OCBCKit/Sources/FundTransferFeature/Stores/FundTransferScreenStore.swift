import AppCore
import Dependencies
import FundTransferCore
import Observation

@MainActor
@Observable
final class FundTransferScreenStore {
    @ObservationIgnored
    @Dependency(\.fundTransferClient)
    private var fundTransferClient

    var state: ScreenState<FundTransferUiModel> = .loading

    func task() async {
        do {
            let account = try await fundTransferClient.fetchPrimaryAccount()
            state = .success(mapToUiModel(account))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load fund transfer.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: FundTransferPrimaryAccount) -> FundTransferUiModel {
        FundTransferUiModel(
            symbol: "arrow.left.arrow.right",
            title: data.accountName.isEmpty ? "Fund Transfer" : data.accountName
        )
    }
}

struct FundTransferUiModel {
    let symbol: String
    let title: String
}
