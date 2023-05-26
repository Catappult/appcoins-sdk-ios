//
//  File.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

struct PaymentMethod {
    
    let name: String
    let label: String
    let icon: String
    let status: String
    let message: String?
    let fee: String?
    
    init(name: String, label: String, icon: String, status: String, message: String?, fee: String?) {
        self.name = name
        self.label = label
        self.icon = icon
        self.status = status
        self.message = message
        self.fee = fee
    }
    
    init(raw: PaymentMethodsRaw) {
        self.name = raw.name
        self.label = raw.label
        self.icon = raw.icon
        self.status = raw.status
        self.message = raw.message
        self.fee = raw.fee
    }
    
}
