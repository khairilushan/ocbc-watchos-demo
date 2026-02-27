import Foundation
import Testing
@testable import Networking
@testable import WithdrawalCore

@Test
func validate_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder3()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/validation")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient3(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture3,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator3(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider3(value: "Fri Feb 27 14:54:01 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider3(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider3(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner3(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let requestPayload = WithdrawalValidationRequest(
        amount: .init(code: "200000", value: "IDR 200,000"),
        benePhoneNumber: "qYKWMAtrwHrkkfEk9DacUw==",
        pin: "",
        remitterPhoneNumber: "qYKWMAtrwHrkkfEk9DacUw==",
        sourceOfFund: .init(
            productCode: "TBSMCY9902",
            productName: "Tanda360Plus-Digital",
            accountNo: "693810029464",
            accountType: "S",
            bankCode: "999",
            branchCode: "99693",
            mcBit: "Y",
            dynamicAccountId: "",
            accountBalances: [
                .init(
                    accountCcy: "IDR",
                    accountCcyNameEN: "Indonesian Rupiah",
                    accountCcyNameID: "Rupiah Indonesia",
                    balance: 999558224.26,
                    holdBalance: 0,
                    isAvailable: true
                )
            ]
        ),
        withdrawalType: "OTP"
    )

    let result = try await client.validate(requestPayload)
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/card/withdrawal/validation")
    #expect(request.value(forHTTPHeaderField: "URI") == "/card/withdrawal/validation")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let body = try #require(request.httpBody)
    let bodyText = String(data: body, encoding: .utf8) ?? ""
    #expect(bodyText.contains("\"withdrawalType\":\"OTP\""))
    #expect(bodyText.contains("\"accountNo\":\"693810029464\""))

    #expect(result.withdrawalType == "OTP")
    #expect(result.amountCode == "100000")
    #expect(result.amountValue == "IDR 100,000")
    #expect(result.sourceOfFundAccountNo == "693800000723")
    #expect(result.onlineSessionId == "693810053779--1000000-30ad6495-318e-4969-9850-e560b1ad3af0")
}

private actor RequestRecorder3 {
    private var request: URLRequest?

    func set(request: URLRequest) {
        self.request = request
    }

    func latestRequest() -> URLRequest? {
        request
    }
}

private struct SpyHTTPClient3: HTTPClient {
    let recorder: RequestRecorder3
    let result: (Data, URLResponse)

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        await recorder.set(request: request)
        return result
    }
}

private struct FixedNonceGenerator3: NonceGenerator {
    let value: String

    func makeNonce() -> String { value }
}

private struct FixedTimestampProvider3: TimestampProvider {
    let value: String

    func now() -> Date { .distantPast }

    func string(from date: Date) -> String { value }
}

private struct FixedSessionProvider3: SessionProvider {
    let value: String?

    func currentSessionID() async -> String? { value }
}

private struct FixedAccessTokenProvider3: AccessTokenProvider {
    let value: String?

    func currentAccessToken() async -> String? { value }
}

private struct FixedSigner3: RequestSigner {
    let value: String

    func sign(apiKey: String, nonce: String, timestamp: String, uri: String) throws -> String { value }
}

private extension NetworkingConfig {
    static var fixture3: Self {
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
  "responseDescription": "SUKSES",
  "responseTitle": "",
  "language": "IN",
  "response_code": "00000",
  "data": {
    "withdrawalType": "OTP",
    "remitterPhoneNumber": "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
    "sourceOfFund": {
      "productCode": "GRRMCY9902",
      "productName": "GIRO BUSINESS SMART",
      "accountNo": "693800000723",
      "accountType": "D",
      "branchCode": "99693",
      "mcBit": "Y",
      "accountId": "AE28BF3D6C4EDA13E050A8C0940711A9",
      "labelDebitAccount": "GIRO BUSINESS SMART 693800000723 IDR 65200583.00",
      "cif": "0000000000001679512",
      "accountBalances": [
        {
          "accountCcy": "IDR",
          "balance": 65200583,
          "isAvailable": true
        }
      ]
    },
    "benePhoneNumber": "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
    "amount": {
      "code": "100000",
      "value": "IDR 100,000"
    },
    "pin": "NSxrnI2hxFSOlfeqCnagHqTQVJ57kSXJWGVI62Yd3Xc=",
    "onlineSessionId": "693810053779--1000000-30ad6495-318e-4969-9850-e560b1ad3af0"
  }
}
"""
