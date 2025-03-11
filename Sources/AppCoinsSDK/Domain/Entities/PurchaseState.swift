//
//  PurchaseState.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation

internal enum PurchaseState {
    case none
    case loading
    case paying
    case processing
    case success
    case failed
    case nointernet
}
