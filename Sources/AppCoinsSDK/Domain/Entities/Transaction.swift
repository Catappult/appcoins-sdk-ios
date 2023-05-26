//
//  File.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

struct Transaction {
    
    let uid: String
    let domain: String
    let product: String
    let walletFrom: String
    let country: String
    let type: String
    let reference: String?
    let hash: String?
    let origin: String
    let status: String
    let developerPayload: String?
    let purchaseUID: String?
    let priceCurrency: String?
    let priceValue: String?
    let priceAppc: String?
    
    init(uid: String, domain: String, product: String, walletFrom: String, country: String, type: String, reference: String?, hash: String?, origin: String, status: String, developerPayload: String?, purchaseUID: String?, priceCurrency: String?, priceValue: String?, priceAppc: String?) {
        self.uid = uid
        self.domain = domain
        self.product = product
        self.walletFrom = walletFrom
        self.country = country
        self.type = type
        self.reference = reference
        self.hash = hash
        self.origin = origin
        self.status = status
        self.developerPayload = developerPayload
        self.purchaseUID = purchaseUID
        self.priceCurrency = priceCurrency
        self.priceValue = priceValue
        self.priceAppc = priceAppc
    }
    
    init(raw: GetTransactionInfoRaw) {
        self.uid = raw.uid
        self.domain = raw.domain
        self.product = raw.product
        self.walletFrom = raw.wallet_from
        self.country = raw.country
        self.type = raw.type
        self.reference = raw.reference
        self.hash = raw.hash
        self.origin = raw.origin
        self.status = raw.status
        self.developerPayload = raw.metadata?.developer_payload
        self.purchaseUID = raw.metadata?.purchase_uid
        self.priceCurrency = raw.price?.currency
        self.priceValue = raw.price?.value
        self.priceAppc = raw.price?.appc
    }
    
}
