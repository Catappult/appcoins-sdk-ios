//
//  TransactionParameters.swift
//  
//
//  Created by aptoide on 20/10/2023.
//

import Foundation

internal struct TransactionParameters {
    
    // new transactionParameters
    internal let country: String?
    internal let address: String?
    internal let signature: String?
    internal let paymentChannel: String?
    internal let token: String?
    internal let origin: String?
    internal let product: String
    internal let domain: String
    internal let type: String?
    internal let oemID: String?
    internal let reference: String?
    internal let promoCode: String?
    internal let guestUID: String?
    internal let metadata: String?
    internal let period: String
    internal let trialPeriod: String
    internal let userProps: String
    
    // old transactionParameters
    internal let value: String
    internal let currency: String
    internal let appcAmount: String
    internal var method: String?
    
    let queryKeys: [String : String] = [
        "country" : "country",
        "address" : "address",
        "signature" : "signature",
        "paymentChannel" : "payment_channel",
        "token" : "token",
        "origin" : "origin",
        "product" : "product",
        "domain" : "domain",
        "type" : "type",
        "oemID" : "oem_id",
        "reference" : "reference",
        "promoCode" : "promo_code",
        "guestUID" : "guest_id",
        "metadata" : "metadata",
        "period" : "period",
        "trialPeriod" : "trial_period",
        "userProps" : "user_props"
    ]

    init(country: String, address: String, signature: String, paymentChannel: String, token: String, origin: String, product: String, domain: String, type: String, oemID: String?, reference: String?, promoCode: String, guestUID: String?, metadata: String?, period: String, trialPeriod: String, userProps: String, value: String, currency: String, appcAmount: String, method: String? = nil) {
        self.country = country
        self.address = address
        self.signature = signature
        self.paymentChannel = paymentChannel
        self.token = token
        self.origin = origin
        self.product = product
        self.domain = domain
        self.type = type
        self.oemID = oemID
        self.reference = reference
        self.promoCode = promoCode
        self.guestUID = guestUID
        self.metadata = metadata
        self.period = period
        self.trialPeriod = trialPeriod
        self.userProps = userProps
        
        self.value = value
        self.currency = currency
        self.appcAmount = appcAmount
        self.method = method
    }
    
    internal mutating func setMethod(method: Method) { self.method = method.rawValue }
    
    internal func asQueryItems() -> [URLQueryItem] {
        let mirror = Mirror(reflecting: self)

        return mirror.children.compactMap { (label, value) in
            guard let label = label, let value = value as? String else { return nil }
            
            if let mappedKey = queryKeys[label] { return URLQueryItem(name: mappedKey, value: value) }

            return nil
        }
    }
    
    internal func createWebCheckoutURL() -> URL? {
        var components = URLComponents(string: BuildConfiguration.appCoinsWebCheckoutURL)
        components?.queryItems = asQueryItems()
        
        return components?.url
    }
}
