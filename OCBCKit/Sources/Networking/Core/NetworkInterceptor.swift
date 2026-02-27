import Foundation

public protocol NetworkInterceptor: Sendable {
    func willSend(_ request: URLRequest, context: RequestContext) async throws -> URLRequest
    func didReceive(data: Data, response: HTTPURLResponse, for request: URLRequest, durationMs: Int) async
    func didFail(_ error: Error, for request: URLRequest, durationMs: Int) async
}

public extension NetworkInterceptor {
    func willSend(_ request: URLRequest, context: RequestContext) async throws -> URLRequest {
        request
    }

    func didReceive(data: Data, response: HTTPURLResponse, for request: URLRequest, durationMs: Int) async {}

    func didFail(_ error: Error, for request: URLRequest, durationMs: Int) async {}
}
