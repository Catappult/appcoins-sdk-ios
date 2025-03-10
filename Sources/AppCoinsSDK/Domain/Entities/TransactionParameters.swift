//
//  TransactionParameters.swift
//
//
//  Created by aptoide on 20/10/2023.
//

import Foundation

internal struct TransactionParameters {
    
    internal let value: String
    internal let currency: String
    internal let domain: String
    internal let product: String
    internal var method: String?
    internal let guestUID: String?
    internal let oemID: String?
    internal let metadata: String?
    internal let reference: String?
    
    init(value: String, currency: String, domain: String, product: String, method: String? = nil, guestUID: String?, oemID: String?, metadata: String?, reference: String?) {
        self.value = value
        self.currency = currency
        self.domain = domain
        self.product = product
        self.method = method
        self.guestUID = guestUID
        self.oemID = oemID
        self.metadata = metadata
        self.reference = reference
    }
}
