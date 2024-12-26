//
//  PurchaseState.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation

internal enum PurchaseState {
    case none
    case paying
    case adyen
    case processing
    case success
    case failed
    case nointernet
}
