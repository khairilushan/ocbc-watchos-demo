import Foundation
import Testing
import TestSupport
@testable import Networking
@testable import WithdrawalCore

@Test
func fetchConfiguration_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/parameter/withdrawal-amount")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .testFixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:50:57 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let client = WithdrawalClient.live(apiClient: apiClient)
    let config = try await client.fetchAmountConfiguration(.otp)
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/parameter/withdrawal-amount")
    #expect(request.value(forHTTPHeaderField: "URI") == "/parameter/withdrawal-amount")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(String(data: request.httpBody ?? Data(), encoding: .utf8) == "{\"withdrawalType\":\"OTP\"}")

    #expect(config.minimumAmount == 100000)
    #expect(config.maximumAmount == 2500000)
    #expect(config.denominationAmount == 100000)
    #expect(config.parameters.count == 2)
    #expect(config.parameters[0] == .init(code: "100000", value: "IDR 100,000"))
    #expect(config.parameters[1] == .init(code: "200000", value: "IDR 200,000"))
}

private let sampleResponse = """
{
  "response_code": "00000",
  "responseDescription": "SUCCESS",
  "responseTitle": "",
  "language": "EN",
  "data": {
    "parameters": [
      {
        "code": "100000",
        "value": "IDR 100,000"
      },
      {
        "code": "200000",
        "value": "IDR 200,000"
      }
    ],
    "minimumAmount": 100000,
    "maximumAmount": 2500000,
    "denominationAmount": 100000
  }
}
"""
