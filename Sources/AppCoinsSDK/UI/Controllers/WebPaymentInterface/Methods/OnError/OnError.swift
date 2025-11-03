//
//  OnError.swift
//  
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

internal class OnError {
    
    internal static let shared = OnError()
    
    private init() {}
    
    internal func handle(body: OnErrorBody) {
        let error: AppCoinsSDKError = AppCoinsSDKError.fromWebCheckoutError(body: body)
        Utils.log("Checkout failed with error: \(error)")
        PurchaseViewModel.shared.failed(error: error)
    }
    
    internal func handle(query: OnErrorQuery) {
        let error: AppCoinsSDKError = AppCoinsSDKError.fromWebCheckoutError(query: query)
        Utils.log("Checkout failed with error: \(error)")
        PurchaseViewModel.shared.failed(error: error)
    }
}
