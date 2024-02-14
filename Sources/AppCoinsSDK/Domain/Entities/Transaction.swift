//
//  Transaction.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

internal struct Transaction {
    
    internal let uid: String
    internal let domain: String
    internal let product: String
    internal let walletFrom: String?
    internal let country: String?
    internal let type: String?
    internal let reference: String?
    internal let hash: String?
    internal let origin: String?
    internal let status: String
    internal let developerPayload: String?
    internal let purchaseUID: String?
    internal let priceCurrency: String?
    internal let priceValue: String?
    internal let priceAppc: String?
    
    internal init(uid: String, domain: String, product: String, walletFrom: String?, country: String?, type: String?, reference: String?, hash: String?, origin: String?, status: String, developerPayload: String?, purchaseUID: String?, priceCurrency: String?, priceValue: String?, priceAppc: String?) {
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
    
    internal init(raw: GetTransactionInfoRaw) {
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
