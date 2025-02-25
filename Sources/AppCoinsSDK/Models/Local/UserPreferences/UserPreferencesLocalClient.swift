//
//  UserPreferencesLocalClient.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal class UserPreferencesLocalClient: UserPreferencesLocalService {
    
    internal func getLastPaymentMethod() -> Method? {
        return Method(rawValue: Utils.readFromPreferences(key: "last-payment-method"))
    }
    
    internal func setLastPaymentMethod(paymentMethod: Method) {
        try? Utils.writeToPreferences(key: "last-payment-method", value: paymentMethod.rawValue)
    }
    
    internal func getWalletBA(wa: String) -> String {
        return Utils.readFromPreferences(key: "\(wa)-BA")
    }
    
    // stores locally wether the wallet has a billing agreement with PayPal active
    internal func writeWalletBA(wa: String) {
        try? Utils.writeToPreferences(key: "\(wa)-BA", value: "true")
    }
    
    internal func removeWalletBA(wa: String) {
        Utils.deleteFromPreferences(key: "\(wa)-BA")
    }
    
    internal func isSDKDefault() -> String? {
        let isSDKDefault: String = Utils.readFromPreferences(key: "is-sdk-default")
        return isSDKDefault == "" ? nil : isSDKDefault
    }
    
    internal func setSDKDefault(value: String) {
        try? Utils.writeToPreferences(key: "is-sdk-default", value: value)
    }
}
