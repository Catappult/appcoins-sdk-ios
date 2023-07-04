//
//  File.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

struct PaymentMethod: Hashable {
    
    let name: String
    let label: String
    let icon: String
    let status: String
    let message: String?
    let gateway: String?
    let fee: String?
    var disabled: Bool
    
    init(name: String, label: String, icon: String, status: String, message: String?, gateway: String?, fee: String?, disabled: Bool = false) {
        self.name = name
        self.label = label
        self.icon = icon
        self.status = status
        self.message = message
        self.gateway = gateway
        self.fee = fee
        self.disabled = disabled
    }
    
    init(raw: PaymentMethodsRaw) {
        self.name = raw.name
        self.label = raw.label
        self.icon = raw.icon
        self.status = raw.status
        self.message = raw.message
        self.gateway = raw.gateway?.name
        self.fee = raw.fee
        self.disabled = false
    }

}
