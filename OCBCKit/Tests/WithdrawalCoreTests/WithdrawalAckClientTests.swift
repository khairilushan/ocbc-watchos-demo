import Foundation
import Testing
import TestSupport
@testable import Networking
@testable import WithdrawalCore

@Test
func acknowledge_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleAckResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/ack")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .testFixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:54:27 GMT+01:00 2026"),
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
    let recorder = RequestRecorder()
    let data = sampleAckResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/ack")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .testFixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:54:27 GMT+01:00 2026"),
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
