public struct PostVerifyPinResponse: Decodable, Sendable, Equatable {
    public let responseCode: String
    public let responseDescriptionEN: String
    public let responseDescriptionID: String

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescriptionEN = "response_desc_en"
        case responseDescriptionID = "response_desc_id"
    }
}
