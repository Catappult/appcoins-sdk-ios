//
//  PurchaseState.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation

internal enum PurchaseState {
    case none
    case initialAskForSync
    case syncProcessing
    case syncSuccess
    case syncError
    case paying
    case adyen
    case processing
    case success
    case successAskForInstall
    case successAskForSync
    case failed
    case nointernet
    case login
}
