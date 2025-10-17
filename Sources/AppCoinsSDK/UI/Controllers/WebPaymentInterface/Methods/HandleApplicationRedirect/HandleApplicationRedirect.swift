//
//  HandleApplicationRedirect.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 06/05/2025.
//

import SwiftUI

internal class HandleApplicationRedirect {
    
    internal static let shared = HandleApplicationRedirect()
    
    private init() {}
    
    internal func handle(body: HandleApplicationRedirectBody) {
        guard let URL = URL(string: body.URL) else {
            Utils.log("Invalid URL on handleApplicationRedirect")
            return
        }
        
        UIApplication.shared.open(URL, options: [:]) { success in
            if !success { Utils.log("Cannot open URL on handleApplicationRedirect") }
        }
    }
        
}
