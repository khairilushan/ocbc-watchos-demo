import Foundation

public struct RequestBuilder: Sendable {
    public init() {}

    public func makeRequest<E: Endpoint>(
        endpoint: E,
        config: NetworkingConfig
    ) throws -> URLRequest {
        var components = URLComponents(
            url: config.baseURL.appending(path: normalizedPath(endpoint.path)),
            resolvingAgainstBaseURL: false
        )
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    public func normalizedPath(_ rawPath: String) -> String {
        if rawPath.hasPrefix("/") {
            return String(rawPath.dropFirst())
        }
        return rawPath
    }
}
