import Foundation
import Testing
import TestSupport
@testable import Networking
@testable import WithdrawalCore

@Test
func validate_postsBodyAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/validation")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .testFixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:54:01 GMT+01:00 2026"),
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
