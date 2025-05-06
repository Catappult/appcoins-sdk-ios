//
//  HandleInternalRedirect.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 06/05/2025.
//

import SwiftUI

internal class HandleInternalRedirect {
    
    internal static let shared = HandleInternalRedirect()
    
    private init() {}
    
    internal func handle(body: HandleInternalRedirectBody) {
        guard let URL = URL(string: body.URL) else {
            Utils.log("Invalid URL on handleInternalRedirect")
            return
        }
        
        SDKViewController.presentSafariSheet(url: URL)
    }
    
}
