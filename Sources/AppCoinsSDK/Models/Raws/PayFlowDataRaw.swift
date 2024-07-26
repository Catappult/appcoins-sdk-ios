//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 26/07/2024.
//

import Foundation

internal struct PayFlowDataRaw: Codable {
    
//    let paymentMethods: PaymentMethods
//    
//    enum CodingKeys: String, CodingKey {
//        case paymentMethods = "payment_methods"
//    }
//}
//
//internal struct PaymentMethods: Codable {
//    
//    let iosSDK: IOSSdkData
//    
//    enum CodingKeys: String, CodingKey {
//        case iosSDK = "ios_sdk"
//    }
//}
//
//internal struct IOSSdkData: Codable {
    
    let paymentFlow: String
    let version: String
    let priority: Int
    
    enum CodingKeys: String, CodingKey {
        case paymentFlow = "payment_flow"
        case version = "version"
        case priority = "priority"
    }
}
