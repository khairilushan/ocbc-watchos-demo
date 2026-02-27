import Foundation
import Testing
@testable import BalanceCore
@testable import Networking

@Test
func fetchTotalBalances_decodesAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/dashboard/inquiry-balance-total")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let client = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 07:14:15 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )
    let dataSourceClient = BalanceClient.live(apiClient: client)

    let balances = try await dataSourceClient.fetchTotalBalances()
    let request = try #require(await recorder.latestRequest())

    #expect(request.url?.absoluteString == "https://example.com/dashboard/inquiry-balance-total")
    #expect(request.value(forHTTPHeaderField: "URI") == "/dashboard/inquiry-balance-total")
    #expect(balances.count == 2)
    #expect(balances[0].currencyCode == "IDR")
    #expect(balances[0].balance == 1497382669.02)
    #expect(balances[1].currencyCode == "USD")
    #expect(balances[1].balance == 1957483.55)
}

private actor RequestRecorder {
    private var request: URLRequest?

    func set(request: URLRequest) {
        self.request = request
    }

    func latestRequest() -> URLRequest? {
        request
    }
}

private struct SpyHTTPClient: HTTPClient {
    let recorder: RequestRecorder
    let result: (Data, URLResponse)

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

private struct FixedNonceGenerator: NonceGenerator {
    let value: String

    func makeNonce() -> String { value }
}

private struct FixedTimestampProvider: TimestampProvider {
    let value: String

    func now() -> Date { .distantPast }

    func string(from date: Date) -> String { value }
}

private struct FixedSessionProvider: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? { value }
}

private struct FixedAccessTokenProvider: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? { value }
}

private struct FixedSigner: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

private extension NetworkingConfig {
    static var fixture: Self {
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

private let sampleResponse = """
{
  "response_code": "00000",
  "response_desc_en": "SUCCESS",
  "response_desc_id": "SUKSES",
  "data": {
    "listAccountBalanceByCIF": [
      {
        "accountCcyNameID": "IDR ID",
        "accountCcyNameEN": "IDR EN",
        "accountCcy": "IDR",
        "balance": 1497382669.02,
        "isAvailable": true,
        "iconUrl": "https://iOSimage.blob.core.windows.net/payment/voucher-pulsa-isi-ulang.png"
      },
      {
        "accountCcyNameID": "USD ID",
        "accountCcyNameEN": "USD EN",
        "accountCcy": "USD",
        "balance": 1957483.55,
        "isAvailable": true,
        "iconUrl": "https://iOSimage.blob.core.windows.net/payment/voucher-pulsa-isi-ulang.png"
      }
    ]
  }
}
"""
