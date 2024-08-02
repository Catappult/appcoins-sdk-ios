//
//  PayFlowType.swift
//
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal enum PayFlowType: String {
    case standard
    case d2c
    
    init(raw: PayFlowDataRaw) {
        if let paymentFlow = raw.paymentMethods.iosSDK?.paymentFlow {
            switch paymentFlow {
            case "D2C":
                self = .d2c
            default:
                self = .standard
            }
        } else {
            self = .standard
        }
    }
    
    var rawValue: String {
        switch self {
        case .standard:
            return "standard"
        case .d2c:
            return "d2c"
        }
    }
}
