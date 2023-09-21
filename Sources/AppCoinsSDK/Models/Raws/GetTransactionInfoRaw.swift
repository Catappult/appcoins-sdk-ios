//
//  File.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

struct GetTransactionInfoRaw: Codable {
    
    let uid: String
    let domain: String
    let product: String
    let wallet_from: String
    let country: String
    let type: String
    let reference: String?
    let hash: String?
    let origin: String
    let status: String
    let gateway: GetTransactionInfoGatewayRaw?
    let metadata: GetTransactionInfoMetadataRaw?
    let price: GetTransactionInfoPriceRaw?
    
    enum CodingKeys: String, CodingKey {
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

struct GetTransactionInfoGatewayRaw: Codable {
    
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
}

struct GetTransactionInfoMetadataRaw: Codable {
    
    let developer_payload: String?
    let purchase_uid: String?

    enum CodingKeys: String, CodingKey {
        case developer_payload = "developer_payload"
        case purchase_uid = "purchase_uid"
    }
    
}

struct GetTransactionInfoPriceRaw: Codable {
    
    let currency: String?
    let value: String?
    let appc: String?

    enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case value = "value"
        case appc = "appc"
    }
    
}

