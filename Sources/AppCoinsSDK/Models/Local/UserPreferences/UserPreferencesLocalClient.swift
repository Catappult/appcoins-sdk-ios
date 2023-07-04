//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

class UserPreferencesLocalClient : UserPreferencesLocalService {
    
    func getLastPaymentMethod() -> String {
        return Utils.readFromPreferences(key: "last-payment-method")
    }
    
    func setLastPaymentMethod(paymentMethod: String) {
        try? Utils.writeToPreferences(key: "last-payment-method", value: paymentMethod)
    }
    
    func getWalletBA(wa: String) -> String {
        return Utils.readFromPreferences(key: "\(wa)-BA")
    }
    
    // stores locally wether the wallet has a billing agreement with PayPal active
    func writeWalletBA(wa: String) {
        try? Utils.writeToPreferences(key: "\(wa)-BA", value: "true")
    }
    
    func removeWalletBA(wa: String) {
        Utils.deleteFromPreferences(key: "\(wa)-BA")
    }
}
