public struct PinVerificationResult: Sendable, Equatable {
    public let responseCode: String
    public let responseDescriptionEN: String
    public let responseDescriptionID: String

    public init(responseCode: String, responseDescriptionEN: String, responseDescriptionID: String) {
        self.responseCode = responseCode
        self.responseDescriptionEN = responseDescriptionEN
        self.responseDescriptionID = responseDescriptionID
    }
}
