import AppCore

struct HomeMenuItem: Identifiable {
    let id: Destination
    let title: String
    let symbol: String
    let destination: Destination
    let isMultiline: Bool

    var accessibilityLabel: String {
        title.replacingOccurrences(of: "\n", with: " ")
    }

    static let items: [Self] = [
        .init(id: .balance, title: "Account Balance", symbol: "person.text.rectangle", destination: .balance, isMultiline: false),
        .init(id: .qris, title: "QRIS Pay", symbol: "qrcode.viewfinder", destination: .qris, isMultiline: false),
        .init(id: .withdrawal, title: "Withdrawal", symbol: "banknote", destination: .withdrawal, isMultiline: false),
        .init(id: .fundTransfer, title: "Fund Transfer", symbol: "arrow.left.arrow.right", destination: .fundTransfer, isMultiline: false),
        .init(id: .payment, title: "Payment &\nPurchase", symbol: "creditcard", destination: .payment, isMultiline: true)
    ]
}
