import Foundation
import Testing
import TestSupport
@testable import Networking
@testable import WithdrawalCore

@Test
func fetchAccounts_requestsEndpointAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleSourceOfFundsResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/card/withdrawal/source-of-funds")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .testFixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:50:38 GMT+01:00 2026"),
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
    let accounts = try await client.fetchSourceOfFunds()
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "GET")
    #expect(request.url?.absoluteString == "https://example.com/card/withdrawal/source-of-funds")
    #expect(request.value(forHTTPHeaderField: "URI") == "/card/withdrawal/source-of-funds")

    #expect(accounts.count == 2)
    #expect(accounts[0].productCode == "TBSMCY9902")
    #expect(accounts[0].accountNo == "693810029464")
    #expect(accounts[0].accountCcy == "IDR")
    #expect(accounts[0].balance == 999558224.26)
    #expect(accounts[0].isAvailable == true)
}

private let sampleSourceOfFundsResponse = """
{
  "responseDescription": "SUKSES",
  "responseTitle": "",
  "language": "IN",
  "response_code": "00000",
  "data": {
    "accounts": [
      {
        "productCode": "TBSMCY9902",
        "productName": "Tanda360Plus-Digital",
        "accountNo": "693810029464",
        "accountType": "S",
        "accountCcy": "",
        "branchCode": "99693",
        "mcBit": "Y",
        "dynamicAccountId": "",
        "bankCode": "999",
        "bankName": "",
        "description": "",
        "qrCode": "",
        "accountBalances": [
          {
            "accountCcy": "IDR",
            "balance": 999558224.26,
            "holdBalance": 0,
            "isAvailable": true,
            "accountCcyNameID": "Rupiah Indonesia",
            "accountCcyNameEN": "Indonesian Rupiah"
          }
        ]
      },
      {
        "productCode": "GRRMCY9902",
        "productName": "GIRO BUSINESS SMART",
        "accountNo": "693800005375",
        "accountType": "D",
        "accountCcy": "",
        "branchCode": "99693",
        "mcBit": "Y",
        "dynamicAccountId": "",
        "bankCode": "999",
        "bankName": "",
        "description": "",
        "qrCode": "",
        "accountBalances": [
          {
            "accountCcy": "IDR",
            "balance": 45141301,
            "holdBalance": 0,
            "isAvailable": true,
            "accountCcyNameID": "Rupiah Indonesia",
            "accountCcyNameEN": "Indonesian Rupiah"
          }
        ]
      }
    ]
  }
}
"""
