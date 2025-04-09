//
//  HandleAuthenticationRedirect.swift
//
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

internal class HandleAuthenticationRedirect {
    
    internal static func handle(body: HandleAuthenticationRedirectBody) {
        BottomSheetViewModel.shared.presentAuthenticationRedirect(redirectURL: body.URL)
    }
    
}
