//
//  GetTransactionInfoRaw.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

internal struct GetTransactionInfoRaw: Codable {
    
    internal let uid: String
    internal let domain: String
    internal let product: String
    internal let wallet_from: String
    internal let country: String
    internal let type: String
    internal let reference: String?
    internal let hash: String?
    internal let origin: String
    internal let status: String
    internal let gateway: GetTransactionInfoGatewayRaw?
    internal let metadata: GetTransactionInfoMetadataRaw?
    internal let price: GetTransactionInfoPriceRaw?
    
    internal enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case domain = "domain"
        case product = "product"
        case wallet_from = "wallet_from"
        case country = "country"
        case type = "type"
        case reference = "reference"
        case hash = "hash"
        case origin = "origin"
        case status = "status"
        case gateway = "gateway"
        case metadata = "metadata"
        case price = "price"
    }
    
}

internal struct GetTransactionInfoGatewayRaw: Codable {
    
    internal let name: String

    internal enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
}

internal struct GetTransactionInfoMetadataRaw: Codable {
    
    internal let developer_payload: String?
    internal let purchase_uid: String?

    internal enum CodingKeys: String, CodingKey {
        case developer_payload = "developer_payload"
        case purchase_uid = "purchase_uid"
    }
    
}

internal struct GetTransactionInfoPriceRaw: Codable {
    
    internal let currency: String?
    internal let value: String?
    internal let appc: String?

    internal enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case value = "value"
        case appc = "appc"
    }
    
}

