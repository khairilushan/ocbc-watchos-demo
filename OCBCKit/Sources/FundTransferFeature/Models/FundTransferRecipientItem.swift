import Foundation

struct FundTransferRecipientItem: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let accountName: String
    let nickname: String
    let bankName: String
    let accountNo: String
    let accountCurrency: String
    let isFavorite: Bool
}
