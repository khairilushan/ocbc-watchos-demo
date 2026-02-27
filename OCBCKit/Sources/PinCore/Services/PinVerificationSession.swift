public actor PinVerificationSession {
    public static let shared = PinVerificationSession()

    private var verifiedPins: [String: String] = [:]

    public init() {}

    public func setVerifiedPin(_ pin: String, for appliNumber: String) {
        verifiedPins[appliNumber] = pin
    }

    public func verifiedPin(for appliNumber: String) -> String? {
        verifiedPins[appliNumber]
    }

    public func clear(for appliNumber: String) {
        verifiedPins.removeValue(forKey: appliNumber)
    }
}
