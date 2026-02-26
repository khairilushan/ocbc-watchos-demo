struct BalanceAccount: Identifiable {
    let id: String
    let flag: String
    let currency: String
    let amount: String

    static let sample: [Self] = [
        .init(id: "idr", flag: "🇮🇩", currency: "IDR", amount: "1,497,382,669.02"),
        .init(id: "usd", flag: "🇺🇸", currency: "USD", amount: "1,957,483.55"),
        .init(id: "sgd", flag: "🇸🇬", currency: "SGD", amount: "1,046,737.69"),
        .init(id: "eur", flag: "🇪🇺", currency: "EUR", amount: "884,251.44"),
        .init(id: "jpy", flag: "🇯🇵", currency: "JPY", amount: "22,140,983.00"),
        .init(id: "gbp", flag: "🇬🇧", currency: "GBP", amount: "713,902.18"),
        .init(id: "aud", flag: "🇦🇺", currency: "AUD", amount: "1,102,645.70")
    ]
}
