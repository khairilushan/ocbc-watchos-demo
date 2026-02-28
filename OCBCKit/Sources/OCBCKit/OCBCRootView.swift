import AppCore
import BalanceFeature
import FundTransferFeature
import HomeFeature
import PaymentFeature
import PinFeature
import QrisFeature
import SwiftUI
import WithdrawalFeature

public struct OCBCRootView: View {
    @State private var router = Router()

    public init() {}

    public var body: some View {
        NavigationStack(path: $router.path) {
            HomeScreen()
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .home:
                        HomeScreen()
                    case .balance:
                        BalanceScreen()
                    case .qris:
                        QRISRequestMoneyScreen()
                    case .fundTransfer:
                        FundTransferRecipientScreen()
                    case let .fundTransferAmountInput(recipient):
                        FundTransferAmountInputScreen(recipient: recipient)
                    case .payment:
                        PaymentView()
                    case .withdrawal:
                        WithdrawalScreen()
                    case let .pin(appliNumber, sequenceNumber, next):
                        PinInputScreen(
                            appliNumber: appliNumber,
                            sequenceNumber: sequenceNumber,
                            nextDestination: next
                        )
                    case .withdrawalVerification:
                        WithdrawalVerificationScreen()
                    }
                }
        }
        .environment(\.router, router)
    }
}

#Preview {
    OCBCRootView()
}
