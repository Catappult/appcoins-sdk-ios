//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

public protocol UserPreferencesLocalService {
    
    // Last Payment Method
    func getLastPaymentMethod() -> String
    func setLastPaymentMethod(paymentMethod: String)
    
    // Wallet Billing Agreement
    func getWalletBA(wa: String) -> String
    func writeWalletBA(wa: String)
    func removeWalletBA(wa: String)
}
