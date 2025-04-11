//
//  TransactionViewModel.swift
//
//
//  Created by aptoide on 19/10/2023.
//

import Foundation

// Helper to the BottomSheetViewModel
internal class TransactionViewModel: ObservableObject {
    
    internal static var shared: TransactionViewModel = TransactionViewModel()
    internal var bottomSheetViewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    // Transaction attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    internal var webCheckoutURL: URL? = nil
    internal var webCheckout: WebCheckout?
    
    private init() {}
    
    internal func reset() {
        self.product = nil
        self.domain = nil
        self.metadata = nil
        self.reference = nil
        self.webCheckoutURL = nil
        self.webCheckout = nil
    }
    
    // Called when a user starts a product purchase
    internal func setUpTransaction(product: Product, domain: String, metadata: String?, reference: String?) {
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
    }
    
    internal func buildTransaction() {
        if let product = product, let domain = domain {
            DispatchQueue.main.async {
                let guestUID = MMPUseCases.shared.getGuestUID()
                
                // 1. Build the parameters to process the transaction
                self.webCheckout = WebCheckout(domain: domain, product: product.sku, metadata: self.metadata, reference: self.reference, guestUID: guestUID)
                
                // 2. Create web checkout URL
                self.webCheckoutURL = self.webCheckout?.getURL()
                
                // 3. Show loaded view
                self.bottomSheetViewModel.setWebCheckoutState(newState: .inCheckout)
            }
        } else { bottomSheetViewModel.transactionFailedWith(error: .systemError(message: "Failed to build transaction", description: "Missing required parameters: product is nil or domain is nil at TransactionViewModel.swift:buildTransaction"))
        }
    }
}
