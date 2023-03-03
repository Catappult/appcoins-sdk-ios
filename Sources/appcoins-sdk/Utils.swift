//
//  Utils.swift
//  appcoins-sdk
//
//  Created by aptoide on 03/03/2023.
//

import Foundation

struct Utils {
 
    static func readFromPreferences(key: String) -> String {
        let preferences = UserDefaults.standard
        return preferences.string(forKey: key) ?? ""
    }
    
}
