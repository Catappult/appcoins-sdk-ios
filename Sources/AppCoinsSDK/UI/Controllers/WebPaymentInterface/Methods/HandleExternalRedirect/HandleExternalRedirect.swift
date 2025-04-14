//
//  HandleExternalRedirect.swift
//  
//
//  Created by aptoide on 10/04/2025.
//

import SwiftUI

internal class HandleExternalRedirect {
    
    internal static let shared = HandleExternalRedirect()
    
    private init() {}
    
    internal func handle(body: HandleExternalRedirectBody) {
        guard let URL = URL(string: body.URL) else {
            Utils.log("Invalid URL on handleExternalRedirect")
            return
        }

        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        } else {
            Utils.log("Cannot open URL on handleExternalRedirect")
        }
    }
    
}
