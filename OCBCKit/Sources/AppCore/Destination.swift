public indirect enum Destination: Hashable, Sendable {
    case home
    case balance
    case qris
    case fundTransfer
    case fundTransferAmountInput(FundTransferRecipientContext)
    case payment
    case withdrawal
    case pin(appliNumber: String, sequenceNumber: String, next: Destination)
    case withdrawalVerification
}
