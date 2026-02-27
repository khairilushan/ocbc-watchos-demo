import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case requestBuildFailed
    case transport(Error)
    case unauthorized
    case forbidden
    case httpStatus(code: Int, data: Data?)
    case decoding(Error)
}
