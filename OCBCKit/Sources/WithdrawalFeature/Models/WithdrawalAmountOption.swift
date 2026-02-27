struct WithdrawalAmountOption: Identifiable, Hashable {
    let id: String
    let code: String
    let value: String

    init(code: String, value: String) {
        self.id = code
        self.code = code
        self.value = value
    }
}
