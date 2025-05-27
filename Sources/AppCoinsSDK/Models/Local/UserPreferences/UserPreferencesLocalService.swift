//
//  UserPreferencesLocalService.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal protocol UserPreferencesLocalService {
    
    // Last Payment Method
    func getLastPaymentMethod() -> Method?
    func setLastPaymentMethod(paymentMethod: Method)
    
    // Wallet Billing Agreement
    func getWalletBA(wa: String) -> String
    func writeWalletBA(wa: String)
    func removeWalletBA(wa: String)
    
    func isSDKDefault() -> String?
    func setSDKDefault(value: String)
}
