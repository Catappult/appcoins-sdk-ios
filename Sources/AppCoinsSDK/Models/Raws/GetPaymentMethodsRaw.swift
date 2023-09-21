//
//  File.swift
//  
//
//  Created by aptoide on 17/05/2023.
//

import Foundation

struct GetPaymentMethodsRaw: Codable {
    
    let items: [PaymentMethodsRaw]?
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
    
}

struct PaymentMethodsRaw: Codable {
    
    let name: String
    let label: String
    let icon: String
    let status: String
    let message: String?
    let gateway: PaymentMethodsGatewayRaw?
    let fee: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case label = "label"
        case icon = "icon"
        case status = "status"
        case message = "message"
        case gateway = "gateway"
        case fee = "fee"
    }
    
}

struct PaymentMethodsGatewayRaw: Codable {
    
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
}
