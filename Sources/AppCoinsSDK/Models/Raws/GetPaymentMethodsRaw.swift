//
//  GetPaymentMethodsRaw.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

internal struct GetPaymentMethodsRaw: Codable {
    
    internal let items: [PaymentMethodsRaw]?
    
    internal enum CodingKeys: String, CodingKey {
        case items = "items"
    }
    
}

internal struct PaymentMethodsRaw: Codable {
    
    internal let name: String
    internal let label: String
    internal let icon: String
    internal let status: String
    internal let message: String?
    internal let gateway: PaymentMethodsGatewayRaw?
    internal let fee: String?
    
    internal enum CodingKeys: String, CodingKey {
        case name = "name"
        case label = "label"
        case icon = "icon"
        case status = "status"
        case message = "message"
        case gateway = "gateway"
        case fee = "fee"
    }
    
}

internal struct PaymentMethodsGatewayRaw: Codable {
    
    internal let name: String?
    
    internal enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
}
