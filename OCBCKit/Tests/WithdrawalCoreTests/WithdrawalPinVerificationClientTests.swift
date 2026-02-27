import Foundation
import Testing
import TestSupport
@testable import Networking
@testable import WithdrawalCore

@Test
func verifyPinOTP_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/token/v3/verify/pin/otp")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .testFixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:54:25 GMT+01:00 2026"),
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
    let result = try await client.verifyPinOTP(
        .init(appliNumber: "1", otpCode: "123456", sequenceNumber: "0")
    )

    let request = try #require(await recorder.latestRequest())
    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/token/v3/verify/pin/otp")
    #expect(request.value(forHTTPHeaderField: "URI") == "/token/v3/verify/pin/otp")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    let body = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
    #expect(body.contains("\"appliNumber\":\"1\""))
    #expect(body.contains("\"otpCode\":\"123456\""))
    #expect(body.contains("\"sequenceNumber\":\"0\""))

    #expect(result.responseCode == "00000")
    #expect(result.responseDescriptionEN == "SUCCESS")
    #expect(result.responseDescriptionID == "SUKSES")
}

private let sampleResponse = """
{
  "response_code": "00000",
  "response_desc_en": "SUCCESS",
  "response_desc_id": "SUKSES"
}
"""
