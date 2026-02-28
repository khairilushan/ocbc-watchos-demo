import Foundation
import Testing
@testable import FundTransferCore
@testable import Networking

@Test
func fetchPrimaryAccount_requestsEndpointAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = sampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/fundtransfer/account/primary")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 14:50:22 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let client = FundTransferClient.live(apiClient: apiClient)
    let account = try await client.fetchPrimaryAccount()
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "GET")
    #expect(request.url?.absoluteString == "https://example.com/fundtransfer/account/primary")
    #expect(request.value(forHTTPHeaderField: "URI") == "/fundtransfer/account/primary")

    #expect(account.hasDefaultAccount == true)
    #expect(account.accountName == "AULIA RACHMAN")
    #expect(account.accountNo == "693810021529")
    #expect(account.accountCcy == "IDR")
    #expect(account.balance == 1586829543)
}

@Test
func fetchRecipients_postsRequestAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = recipientsSampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/recipient/v5/transfer")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 22:09:07 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let client = FundTransferClient.live(apiClient: apiClient)
    let result = try await client.fetchRecipients("IDR", "", 1, 10)
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/recipient/v5/transfer")
    #expect(request.value(forHTTPHeaderField: "URI") == "/recipient/v5/transfer")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let bodyData = try #require(request.httpBody)
    let bodyJSON = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
    #expect(bodyJSON?["category"] as? String == "IDR")
    #expect(bodyJSON?["keyword"] as? String == "")
    let pagination = bodyJSON?["pagination"] as? [String: Any]
    #expect(pagination?["pageNumber"] as? Int == 1)
    #expect(pagination?["pageSize"] as? Int == 10)

    #expect(result.recipients.count == 2)
    #expect(result.recipients[0].accountName == "Steve Jobs")
    #expect(result.recipients[0].isFavorite == true)
    #expect(result.recipients[1].isFavorite == false) // maps "isFavourite"
    #expect(result.pagination.totalData == 35)
}

@Test
func validateTransfer_postsRequestAndMapsResponse() async throws {
    let recorder = RequestRecorder()
    let data = validateSampleResponse.data(using: .utf8)!
    let response = HTTPURLResponse(
        url: URL(string: "https://example.com/fundtransfer/v5/validate")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!
    let httpClient = SpyHTTPClient(recorder: recorder, result: (data, response))

    let apiClient = APIClient(
        config: .fixture,
        httpClient: httpClient,
        nonceGenerator: FixedNonceGenerator(value: "nonce-123"),
        timestampProvider: FixedTimestampProvider(value: "Fri Feb 27 22:10:51 GMT+01:00 2026"),
        sessionProvider: FixedSessionProvider(value: "SESSION123"),
        accessTokenProvider: FixedAccessTokenProvider(value: "TOKEN123"),
        headerProviders: [
            StaticHeadersProvider(),
            SessionHeadersProvider(),
            AuthorizationHeadersProvider(),
            SignatureHeadersProvider(signer: FixedSigner(value: "SIGNED"))
        ]
    )

    let client = FundTransferClient.live(apiClient: apiClient)
    let requestPayload = FundTransferValidationRequest(
        responseCodeOTP: "",
        sourceAccount: .init(
            accountNo: "693810021529",
            accountName: "AULIA RACHMAN",
            accountType: "S",
            dynamicAccountId: "d6658cdc-0a92-4aaa-9474-04e833eb438a",
            productCode: "TBSMCY9901",
            productName: "Tanda360Plus-S",
            accountBalances: [.init(accountCcy: "IDR", balance: 1586829543, isAvailable: true)]
        ),
        listNonRegisteredAccount: [
            .init(
                beneAccount: .init(
                    accountNo: "887711002930",
                    accountName: "Wozniak",
                    accountBalances: [.init(accountCcy: "IDR")],
                    bankCode: "028",
                    bankName: "OCBC NISP"
                ),
                beneTransaction: .init(
                    transferServiceCode: "IFT",
                    amount: "125000",
                    amountCcy: "IDR",
                    interval: "",
                    recurStartDate: "",
                    recurEndDate: "",
                    remark: "test",
                    transferDate: "2026-02-28T04:10:51.168+0700"
                )
            )
        ]
    )

    let result = try await client.validateTransfer(requestPayload)
    let request = try #require(await recorder.latestRequest())

    #expect(request.httpMethod == "POST")
    #expect(request.url?.absoluteString == "https://example.com/fundtransfer/v5/validate")
    #expect(request.value(forHTTPHeaderField: "URI") == "/fundtransfer/v5/validate")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let body = try #require(request.httpBody)
    let bodyText = String(data: body, encoding: .utf8) ?? ""
    #expect(bodyText.contains("\"responseCodeOTP\":\"\""))
    #expect(bodyText.contains("\"accountNo\":\"693810021529\""))
    #expect(bodyText.contains("\"transferServiceCode\":\"IFT\""))

    #expect(result.warningCode == "COT01")
    #expect(result.transactionId == "kjsndf923409123hbs9123has232")
    #expect(result.transferServiceCode == "IFT")
    #expect(result.onlineSessionId == "693810053779--1000000-30ad6495-318e-4969-9850-e560b1ad3af0")
    #expect(result.warningMessage == "Transaksi ini akan diproses pada pukul 04.00 - 14.15 WIB (hari kerja). Dana tidak akan langsung terpotong.")
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
  "responseDescription": "SUKSES",
  "responseTitle": "",
  "language": "IN",
  "data": {
    "hasDefaultAccount": true,
    "account": {
      "productCode": "TBSMCY9901",
      "productName": "Tanda360Plus-S",
      "accountNo": "693810021529",
      "accountType": "S",
      "accountName": "AULIA RACHMAN",
      "accountCcy": "",
      "branchCode": "99693",
      "mcBit": "Y",
      "dynamicAccountId": "d6658cdc-0a92-4aaa-9474-04e833eb438a",
      "bankCode": "",
      "bankName": "",
      "description": "",
      "qrCode": "base64-qr",
      "accountBalances": [
        {
          "accountCcy": "IDR",
          "balance": 1586829543,
          "holdBalance": 0,
          "isAvailable": true,
          "accountCcyNameID": "",
          "accountCcyNameEN": ""
        }
      ]
    }
  },
  "response_code": "00000"
}
"""

private let recipientsSampleResponse = """
{
  "response_code": "00000",
  "response_desc_en": "SUCCESS",
  "data": {
    "recipients": [
      {
        "id": "001",
        "accountNo": "QB7Gg1yxyvuBCR8XJLQ9Gw==",
        "accountName": "Steve Jobs",
        "accountFullname": "Steve Roberto Carlos Jobs",
        "nickname": "Jobs",
        "isFavorite": true,
        "bank": {
          "bankId": "028",
          "swiftCode": "",
          "bankName": "OCBC NISP"
        },
        "transferCategory": "IDR",
        "citizenship": {
          "code": "RS001",
          "value": "WNI",
          "description": "Lorem ipsum dolor sit amet"
        }
      },
      {
        "id": "004",
        "accountNo": "tg0zsK0mg/N6MStOmL2g9w==",
        "accountName": "Yngwie J. Malmsteen",
        "accountFullname": "Yngwie John John Johnny Malmsteen",
        "nickname": "Malmsteen PhoneNumber",
        "isFavourite": false,
        "bank": {
          "bankId": "",
          "swiftCode": "",
          "bankName": ""
        },
        "transferCategory": "IDR",
        "citizenship": {
          "code": "RS001",
          "value": "WNI",
          "description": "Lorem ipsum dolor sit amet"
        }
      }
    ],
    "pagination": {
      "pageNumber": 1,
      "pageSize": 10,
      "totalData": 35
    }
  }
}
"""

private let validateSampleResponse = """
{
  "response_code": "00000",
  "response_desc_en": "SUCCESS",
  "response_desc_id": "SUKSES",
  "data": {
    "warningCode": "COT01",
    "sourceAccount": {
      "accountNo": "693810029464",
      "accountName": "ENDANG MUSTIKOWATI",
      "bankCode": "999",
      "bankName": "OCBCNISP"
    },
    "listNonRegisteredAccount": [
      {
        "beneAccount": {
          "accountNo": "693810030363",
          "accountName": "LISANLY",
          "bankCode": "999",
          "bankName": "OCBCNISP"
        },
        "beneTransaction": {
          "id": "kjsndf923409123hbs9123has232",
          "warningMessage": "Transaksi ini akan diproses pada pukul 04.00 - 14.15 WIB (hari kerja). Dana tidak akan langsung terpotong.",
          "transferServiceCode": "IFT",
          "amount": "25000",
          "amountCcy": "IDR",
          "onlineSessionId": "693810053779--1000000-30ad6495-318e-4969-9850-e560b1ad3af0"
        }
      }
    ]
  }
}
"""
