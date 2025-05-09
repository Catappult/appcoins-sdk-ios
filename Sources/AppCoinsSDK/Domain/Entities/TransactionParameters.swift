//
//  TransactionParameters.swift
//  
//
//  Created by aptoide on 20/10/2023.
//

import Foundation

internal struct TransactionParameters {
    
    internal let value: Double
    internal let currency: Currency
    internal let domain: String
    internal let product: String
    internal let appcAmount: String
    internal var method: String?
    internal let guestUID: String?
    internal let oemID: String?
    internal let metadata: String?
    internal let reference: String?

    init(value: Double, currency: Currency, domain: String, product: String, appcAmount: String, method: String? = nil, guestUID: String?, oemID: String?, metadata: String?, reference: String?) {
        self.value = value
        self.currency = currency
        self.domain = domain
        self.product = product
        self.appcAmount = appcAmount
        self.method = method
        self.guestUID = guestUID
        self.oemID = oemID
        self.metadata = metadata
        self.reference = reference
    }
    
    internal mutating func setMethod(method: Method) { self.method = method.rawValue }
}
