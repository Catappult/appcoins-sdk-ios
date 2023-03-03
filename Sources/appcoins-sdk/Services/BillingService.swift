//
//  BillingService.swift
//  appcoins-sdk
//
//  Created by aptoide on 02/03/2023.
//

import Foundation

public protocol BillingService {
    
    func getPurchases(packageName: String, walletAddress: String, walletSignature: String, type: String)
    
}
