//
//  RedirectHandler.swift
//  
//
//  Created by aptoide on 21/09/2023.
//

import Foundation

public struct RedirectHandler {
    
    static public func handle(redirectURL: URL?) -> Bool {
        if let redirectURL = redirectURL {
            
            if let host = redirectURL.host, host == "wallet.appcoins.io" {
                let pathRoot = redirectURL.pathComponents[1]
                if pathRoot == "sync" {
                    SyncWalletViewModel.shared.importWalletReturn(redirectURL: redirectURL)
                    return true
                }
            } else {
                return AdyenController.shared.handleRedirectURL(redirectURL: redirectURL)
            }
        }
        return false
    }
    
}
