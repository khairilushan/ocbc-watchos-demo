import Foundation

public struct APIClient: Sendable {
    private let config: NetworkingConfig
    private let requestBuilder: RequestBuilder
    private let httpClient: any HTTPClient
    private let nonceGenerator: any NonceGenerator
    private let timestampProvider: any TimestampProvider
    private let sessionProvider: any SessionProvider
    private let accessTokenProvider: any AccessTokenProvider
    private let headerProviders: [any RequestHeaderProvider]
    private let interceptors: [any NetworkInterceptor]

    public init(
        config: NetworkingConfig,
        requestBuilder: RequestBuilder = .init(),
        httpClient: any HTTPClient = URLSessionHTTPClient(),
        nonceGenerator: any NonceGenerator = RandomNonceGenerator(),
        timestampProvider: any TimestampProvider = DefaultTimestampProvider(),
        sessionProvider: any SessionProvider = EmptySessionProvider(),
        accessTokenProvider: any AccessTokenProvider = EmptyAccessTokenProvider(),
        headerProviders: [any RequestHeaderProvider] = [StaticHeadersProvider()],
        interceptors: [any NetworkInterceptor] = []
    ) {
        self.config = config
        self.requestBuilder = requestBuilder
        self.httpClient = httpClient
        self.nonceGenerator = nonceGenerator
        self.timestampProvider = timestampProvider
        self.sessionProvider = sessionProvider
        self.accessTokenProvider = accessTokenProvider
        self.headerProviders = headerProviders
        self.interceptors = interceptors
    }

    public func execute<E: Endpoint>(_ endpoint: E) async throws -> E.Response {
        var request: URLRequest
        do {
            request = try requestBuilder.makeRequest(endpoint: endpoint, config: config)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestBuildFailed
        }

        let context = await makeContext(for: endpoint)
        let startedAt = Date()

        do {
            for provider in headerProviders {
                let headers = try await provider.headers(config: config, context: context)
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }

            for interceptor in interceptors {
                request = try await interceptor.willSend(request, context: context)
            }

            let (data, response) = try await httpClient.send(request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            for interceptor in interceptors {
                await interceptor.didReceive(
                    data: data,
                    response: httpResponse,
                    for: request,
                    durationMs: elapsedMs(since: startedAt)
                )
            }

            switch httpResponse.statusCode {
            case 200 ..< 300:
                break
            case 401:
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            default:
                throw NetworkError.httpStatus(code: httpResponse.statusCode, data: data)
            }

            do {
                return try endpoint.decoder.decode(E.Response.self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch let error as NetworkError {
            for interceptor in interceptors {
                await interceptor.didFail(error, for: request, durationMs: elapsedMs(since: startedAt))
            }
            throw error
        } catch {
            for interceptor in interceptors {
                await interceptor.didFail(error, for: request, durationMs: elapsedMs(since: startedAt))
            }
            throw NetworkError.transport(error)
        }
    }

    private func makeContext<E: Endpoint>(for endpoint: E) async -> RequestContext {
        let nonce = nonceGenerator.makeNonce()
        let timestamp = timestampProvider.string(from: timestampProvider.now())
        let uri = endpoint.path.hasPrefix("/") ? endpoint.path : "/\(endpoint.path)"
        let sessionID = await sessionProvider.currentSessionID()
        let accessToken = await accessTokenProvider.currentAccessToken()

        return RequestContext(
            nonce: nonce,
            timestamp: timestamp,
            uri: uri,
            sessionID: sessionID,
            accessToken: accessToken
        )
    }

    private func elapsedMs(since start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }
}
