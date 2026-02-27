import Foundation
import Testing
@testable import Networking
@testable import WithdrawalCore

@Test
func acknowledge_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder5()
    let data = sampleAckResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/ack")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient5(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture5,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator5(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider5(value: "Fri Feb 27 14:54:27 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider5(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider5(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner5(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let request = makeAckRequest()

    let result = try await client.acknowledge(request)
    let recordedRequest = try #require(await recorder.latestRequest())

    #expect(recordedRequest.httpMethod == "POST")
    #expect(recordedRequest.url?.absoluteString == "https://example.com/card/withdrawal/ack")
    #expect(recordedRequest.value(forHTTPHeaderField: "URI") == "/card/withdrawal/ack")
    #expect(recordedRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let body = String(data: recordedRequest.httpBody ?? Data(), encoding: .utf8) ?? ""
    #expect(body.contains("\"responseCodeOTP\":\"123456\""))
    #expect(body.contains("\"onlineSessionId\":\"693810053779--1000000-30ad6495-318e-4969-9850-e560b1ad3af0\""))

    #expect(result.responseCode == "00000")
    #expect(result.amountCode == "100000")
    #expect(result.transactionOTP == "827382")
    #expect(result.tokenCard == "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=")
}

@Test
func generateToken_usesAckEndpointAndMapsResponse() async throws {
    let recorder = RequestRecorder5()
    let data = sampleAckResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/ack")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient5(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture5,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator5(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider5(value: "Fri Feb 27 14:54:27 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider5(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider5(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner5(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let result = try await client.generateToken(makeAckRequest())
    let recordedRequest = try #require(await recorder.latestRequest())

    #expect(recordedRequest.url?.path == "/card/withdrawal/ack")
    #expect(result.transactionId == "693810053779--1000000-30ad6495-318e-4969-9850-e5")
    #expect(result.transactionOTP == "827382")
}

private func makeAckRequest() -> WithdrawalAckRequest {
    .init(
        amount: .init(code: "100000", value: "IDR 100,000"),
        benePhoneNumber: "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
        onlineSessionID: "693810053779--1000000-30ad6495-318e-4969-9850-e560b1ad3af0",
        pin: "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
        remitterPhoneNumber: "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
        responseCodeOTP: "123456",
        sourceOfFund: .init(
            accountBalances: [.init(accountCcy: "IDR", balance: 65200583, isAvailable: true)],
            accountID: "AE28BF3D6C4EDA13E050A8C0940711A9",
            accountNo: "693800000723",
            accountType: "D",
            branchCode: "99693",
            cif: "0000000000001679512",
            labelDebitAccount: "GIRO BUSINESS SMART 693800000723 IDR 65200583.00",
            mcBit: "Y",
            productCode: "GRRMCY9902",
            productName: "GIRO BUSINESS SMART"
        ),
        withdrawalType: "OTP"
    )
}

private actor RequestRecorder5 {
    private var request: URLRequest?

    func set(request: URLRequest) {
        self.request = request
    }

    func latestRequest() -> URLRequest? {
        request
    }
}

private struct SpyHTTPClient5: HTTPClient {
    let recorder: RequestRecorder5
    let result: (Data, URLResponse)

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

private struct FixedNonceGenerator5: NonceGenerator {
    let value: String

    func makeNonce() -> String { value }
}

private struct FixedTimestampProvider5: TimestampProvider {
    let value: String

    func now() -> Date { .distantPast }

    func string(from date: Date) -> String { value }
}

private struct FixedSessionProvider5: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? { value }
}

private struct FixedAccessTokenProvider5: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? { value }
}

private struct FixedSigner5: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

private extension NetworkingConfig {
    static var fixture5: Self {
        .init(
            baseURL: URL(string: "https://example.com")!,
            apiKey: "apikey-123",
            userAgent: "iOS/4.4.4 (iOS)",
            acceptLanguage: "EN",
            omniChannel: "iOS",
            platform: "iOS",
            appVersion: "4.4.4"
        )
    }
}

private let sampleAckResponse = """
{
  "responseDescription": "SUKSES",
  "responseTitle": "",
  "language": "IN",
  "response_code": "00000",
  "data": {
    "amount": {
      "code": "100000",
      "value": "IDR 100,000"
    },
    "transactionId": "693810053779--1000000-30ad6495-318e-4969-9850-e5",
    "transactionOtp": "827382",
    "tokenCard": "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
    "message": {
      "title": "",
      "subtitle": ""
    }
  }
}
"""
