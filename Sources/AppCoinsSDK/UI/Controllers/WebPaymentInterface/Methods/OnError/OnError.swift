//
//  OnError.swift
//  
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

class OnError {
    
    func handle(body: OnErrorBody) {
        let error: AppCoinsSDKError = AppCoinsSDKError.fromWebCheckoutError(webCheckoutError: body)
        Utils.log("Checkout failed with error: \(error)")
        TransactionViewModel.shared.sendResult(result: .failed(error: error))
    }
}
