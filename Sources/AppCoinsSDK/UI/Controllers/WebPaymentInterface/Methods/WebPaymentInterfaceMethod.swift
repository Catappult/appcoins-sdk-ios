//
//  WebPaymentInterfaceMethod.swift
//  
//
//  Created by aptoide on 04/04/2025.
//

import Foundation

internal enum WebPaymentInterfaceMethod: String {
    case onPurchaseResult = "onPurchaseResult"
    case onError = "onError"
    case handleAuthenticationRedirect = "handleAuthenticationRedirect"
    case handleExternalRedirect = "handleExternalRedirect"
    case handleInternalRedirect = "handleInternalRedirect"
    case setActiveWallet = "setActiveWallet"
}
