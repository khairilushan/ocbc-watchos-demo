import SwiftUI

struct BalanceAccountsListView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(BalanceAccount.sample) { account in
                    BalanceAccountRow(account: account)
                }
            }
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 12)
        .scrollIndicators(.hidden)
    }
}

private struct BalanceAccountRow: View {
    let account: BalanceAccount

    var body: some View {
        HStack(spacing: 10) {
            Text(account.flag)
                .font(.system(size: 18))
                .frame(width: 30, height: 30)
                .background(.white.opacity(0.95), in: Circle())

            VStack(alignment: .leading, spacing: 0) {
                Text(account.currency)
                    .font(.system(size: 17, weight: .bold))
                Text(account.amount)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .foregroundStyle(.white)
        .clipShape(.capsule)
        .glassEffect(
            .regular.tint(.white.opacity(0.08)),
            in: .capsule
        )
    }
}
