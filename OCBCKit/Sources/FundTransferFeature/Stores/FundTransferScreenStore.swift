import AppCore
import Observation

@MainActor
@Observable
final class FundTransferScreenStore {
    var state: ScreenState<FundTransferUiModel> = .loading

    func task() async {
        do {
            try await Task.sleep(for: .seconds(1.0))
            state = .success(mapToUiModel(FundTransferServiceModel.sample))
        } catch is CancellationError {
        } catch {
            state = .failure("Failed to load fund transfer.")
        }
    }

    func retryButtonTapped() async {
        state = .loading
        await task()
    }

    private func mapToUiModel(_ data: FundTransferServiceModel) -> FundTransferUiModel {
        FundTransferUiModel(symbol: data.icon, title: data.title)
    }
}

struct FundTransferUiModel {
    let symbol: String
    let title: String
}

private struct FundTransferServiceModel {
    let icon: String
    let title: String

    static let sample = Self(icon: "arrow.left.arrow.right", title: "Fund Transfer")
}
