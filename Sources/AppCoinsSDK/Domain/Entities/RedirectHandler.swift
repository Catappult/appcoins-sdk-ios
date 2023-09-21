//
//  File.swift
//  
//
//  Created by aptoide on 21/09/2023.
//

import Foundation

public struct RedirectHandler {
    
    static public func handle(redirectURL: URL?) -> Bool {
        return AdyenController.shared.handleRedirectURL(redirectURL: redirectURL)
    }
    
}
