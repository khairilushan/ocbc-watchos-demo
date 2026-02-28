enum FundTransferTransactionTimeOption: String, CaseIterable, Equatable, Sendable {
    case now = "Now"
    case scheduled = "Scheduled"
    case recurring = "Recurring"
}
