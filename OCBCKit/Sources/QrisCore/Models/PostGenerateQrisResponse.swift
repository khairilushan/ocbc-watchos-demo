public struct PostGenerateQrisResponse: Decodable, Sendable, Equatable {
    public struct DataPayload: Decodable, Sendable, Equatable {
        public let encodedQRCode: String
        public let minimumAmount: Int
        public let maximumAmount: Int

        enum CodingKeys: String, CodingKey {
            case encodedQRCode = "encodedQrcode"
            case minimumAmount
            case maximumAmount
        }
    }

    public let responseCode: String
    public let responseDescriptionEN: String
    public let responseDescriptionID: String
    public let data: DataPayload

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseDescriptionEN = "response_desc_en"
        case responseDescriptionID = "response_desc_id"
        case data
    }
}
