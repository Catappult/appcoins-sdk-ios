//
//  PaymentMethod.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

internal struct PaymentMethod: Hashable {
    internal var name: String
    internal let label: String
    internal let icon: String
    internal let status: String
    internal let message: String?
    internal let gateway: String?
    internal let fee: String?
    internal var disabled: Bool
    
    internal init(name: String, label: String, icon: String, status: String, message: String?, gateway: String?, fee: String?, disabled: Bool = false) {
        self.name = name
        self.label = label
        self.icon = icon
        self.status = status
        self.message = message
        self.gateway = gateway
        self.fee = fee
        self.disabled = disabled
    }
    
    internal init(raw: PaymentMethodsRaw) {
        self.name = raw.name
        self.label = raw.label
        self.icon = raw.icon
        self.status = raw.status
        self.message = raw.message
        self.gateway = raw.gateway?.name
        self.fee = raw.fee
        self.disabled = false
    }
    
    internal mutating func disable() { self.disabled = true }
}

internal enum Method: String {
    
    case appc = "appcoins_credits"
    case creditCard = "credit_card"
    case paypalAdyen = "paypal"
    case paypalDirect = "paypal_v2"
    case sandbox = "sandbox"
    
}
