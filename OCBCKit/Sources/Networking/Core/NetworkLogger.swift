import Foundation
import OSLog

public struct NetworkRequestLog: Sendable {
    public var method: String
    public var url: URL
    public var headers: [String: String]
    public var body: Data?

    public init(method: String, url: URL, headers: [String: String], body: Data?) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}

public struct NetworkResponseLog: Sendable {
    public var url: URL?
    public var statusCode: Int
    public var headers: [String: String]
    public var body: Data
    public var durationMs: Int

    public init(url: URL?, statusCode: Int, headers: [String: String], body: Data, durationMs: Int) {
        self.url = url
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.durationMs = durationMs
    }
}

public struct NetworkErrorLog: Sendable {
    public var request: NetworkRequestLog
    public var errorDescription: String
    public var durationMs: Int

    public init(request: NetworkRequestLog, errorDescription: String, durationMs: Int) {
        self.request = request
        self.errorDescription = errorDescription
        self.durationMs = durationMs
    }
}

public protocol NetworkLogger: Sendable {
    func logRequest(_ request: NetworkRequestLog)
    func logResponse(_ response: NetworkResponseLog, for request: NetworkRequestLog)
    func logError(_ error: NetworkErrorLog)
}

public struct NoopNetworkLogger: NetworkLogger {
    public init() {}

    public func logRequest(_ request: NetworkRequestLog) {}
    public func logResponse(_ response: NetworkResponseLog, for request: NetworkRequestLog) {}
    public func logError(_ error: NetworkErrorLog) {}
}

public struct ConsoleNetworkLogger: NetworkLogger {
    private let logger: Logger

    public init() {
        self.init(subsystem: "com.ocbc.watch", category: "networking")
    }
    
    public init(
        subsystem: String = "com.ocbc.watch",
        category: String = "networking"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func logRequest(_ request: NetworkRequestLog) {
        logger.info("➡️ [\(request.method, privacy: .public)] \(request.url.absoluteString, privacy: .public)")
        if !request.headers.isEmpty {
            logger.debug("request-headers:\n\(formattedHeaders(request.headers), privacy: .public)")
        }
        if let body = request.body, !body.isEmpty {
            logger.debug("request-body: \(formattedBody(body), privacy: .public)")
        }
    }

    public func logResponse(_ response: NetworkResponseLog, for request: NetworkRequestLog) {
        logger.info(
            "✅ [\(request.method, privacy: .public)] \(request.url.absoluteString, privacy: .public) status=\(response.statusCode, privacy: .public) duration=\(response.durationMs, privacy: .public)ms"
        )
        if !response.headers.isEmpty {
            logger.debug("response-headers:\n\(formattedHeaders(response.headers), privacy: .public)")
        }
        if !response.body.isEmpty {
            logger.debug("response-body: \(formattedBody(response.body), privacy: .public)")
        }
    }

    public func logError(_ error: NetworkErrorLog) {
        logger.error(
            "❌ [\(error.request.method, privacy: .public)] \(error.request.url.absoluteString, privacy: .public) error=\(error.errorDescription, privacy: .public) duration=\(error.durationMs, privacy: .public)ms"
        )
        if let body = error.request.body, !body.isEmpty {
            logger.debug("request-body: \(formattedBody(body), privacy: .public)")
        }
    }

    private func formattedBody(_ data: Data) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data),
           JSONSerialization.isValidJSONObject(object),
           let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
           let text = String(data: pretty, encoding: .utf8) {
            return text
        }

        if let text = String(data: data, encoding: .utf8) {
            return text
        }

        return "<\(data.count) bytes>"
    }

    private func formattedHeaders(_ headers: [String: String]) -> String {
        headers
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
            .map { "\($0): \($1)" }
            .joined(separator: "\n")
    }
}

public struct NetworkLoggingInterceptor: NetworkInterceptor {
    private let logger: any NetworkLogger

    public init(logger: any NetworkLogger = ConsoleNetworkLogger()) {
        self.logger = logger
    }

    public func willSend(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        logger.logRequest(makeRequestLog(from: request))
        return request
    }

    public func didReceive(data: Data, response: HTTPURLResponse, for request: URLRequest, durationMs: Int) async {
        logger.logResponse(
            NetworkResponseLog(
                url: response.url,
                statusCode: response.statusCode,
                headers: normalizedHeaders(response.allHeaderFields),
                body: data,
                durationMs: durationMs
            ),
            for: makeRequestLog(from: request)
        )
    }

    public func didFail(_ error: Error, for request: URLRequest, durationMs: Int) async {
        logger.logError(
            NetworkErrorLog(
                request: makeRequestLog(from: request),
                errorDescription: String(describing: error),
                durationMs: durationMs
            )
        )
    }

    private func makeRequestLog(from request: URLRequest) -> NetworkRequestLog {
        NetworkRequestLog(
            method: request.httpMethod ?? "UNKNOWN",
            url: request.url ?? URL(string: "about:blank")!,
            headers: request.allHTTPHeaderFields ?? [:],
            body: request.httpBody
        )
    }

    private func normalizedHeaders(_ headers: [AnyHashable: Any]) -> [String: String] {
        var output: [String: String] = [:]
        for (key, value) in headers {
            output[String(describing: key)] = String(describing: value)
        }
        return output
    }
}
