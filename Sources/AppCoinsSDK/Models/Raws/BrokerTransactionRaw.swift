//
//  BrokerTransactionRaw.swift
//

import Foundation

internal struct BrokerTransactionRaw: Codable {
    internal let uid: String?
    internal let domain: String?
    internal let product: String?
    internal let walletFrom: String?
    internal let type: String?
    internal let method: String?
    internal let country: String?
    internal let reference: String?
    internal let hash: String?
    internal let status: String?
    internal let added: String?
    internal let modified: String?
    internal let gateway: BrokerTransactionGatewayRaw?
    internal let metadata: BrokerTransactionMetadataRaw?
    internal let price: BrokerTransactionPriceRaw?
    internal let channel: String?

    internal enum CodingKeys: String, CodingKey {
        case uid, domain, product, type, method, country, reference, hash, status, added, modified, gateway, metadata, price, channel
        case walletFrom = "wallet_from"
    }
}

internal struct BrokerTransactionGatewayRaw: Codable {
    internal let name: String?
}

internal struct BrokerTransactionMetadataRaw: Codable {
    internal let developerPayload: String?
    internal let purchaseUID: String?
    internal let renewal: Bool?
    internal let refusalReason: String?

    internal enum CodingKeys: String, CodingKey {
        case developerPayload = "developer_payload"
        case purchaseUID = "purchase_uid"
        case renewal
        case refusalReason = "refusal_reason"
    }
}

internal struct BrokerTransactionPriceRaw: Codable {
    internal let currency: String?
    internal let value: String?
    internal let appc: String?
    internal let usd: String?
    internal let vat: BrokerTransactionPriceVatRaw?
    internal let discount: BrokerTransactionPriceDiscountRaw?
}

internal struct BrokerTransactionPriceVatRaw: Codable {
    internal let percentage: String?
    internal let value: String?
    internal let usd: String?
}

internal struct BrokerTransactionPriceDiscountRaw: Codable {
    internal let percentage: String?
    internal let value: String?
    internal let usd: String?
}
