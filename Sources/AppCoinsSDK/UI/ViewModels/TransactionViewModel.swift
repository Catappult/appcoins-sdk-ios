//
//  TransactionViewModel.swift
//
//
//  Created by aptoide on 19/10/2023.
//

import Foundation

// Helper to the BottomSheetViewModel
internal class TransactionViewModel : ObservableObject {
    
    internal static var shared : TransactionViewModel = TransactionViewModel()
    
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var bottomSheetViewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    // Transaction attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    @Published internal var transaction: TransactionAlertUi?
    internal var transactionParameters: TransactionParameters?
    
    private init() {}
    
    internal func reset() {
        self.product = nil
        self.domain = nil
        self.metadata = nil
        self.reference = nil
        
        self.transaction = nil
        self.transactionParameters = nil
    }
    
    // Called when a user starts a product purchase
    internal func setUpTransaction(product: Product, domain: String, metadata: String?, reference: String?) {
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
    }
    
    internal func rebuildTransactionOnWalletChanged() {
        self.transaction = nil
        self.transactionParameters = nil
        
        buildTransaction()
    }
    
    internal func buildTransaction() {
        bottomSheetViewModel.setPurchaseState(newState: .loading)
        
        if let product = product, let domain = domain {
            // 1. Get product currency
            product.getCurrency {
                result in
                
                switch result {
                case .success(let productCurrency):
                    // 2. Get user wallet
                    self.walletUseCases.getWallet() {
                        result in
                        
                        switch result {
                        case .success(let wallet):
                            
                            if let moneyAmount = Double(product.priceValue) {
                                
                                // 3. Get user's balance
                                self.getWalletBalance(wallet: wallet) {
                                    balance in
                                    
                                    let balanceValue = balance.balance
                                    let balanceCurrency = balance.balanceCurrency
                                    
                                    DispatchQueue.main.async {
                                        // 4. Build the Transaction UI
                                        self.transaction = TransactionAlertUi(domain: domain, description: product.title, category: .IAP, sku: product.sku, moneyAmount: moneyAmount, moneyCurrency: productCurrency, balanceAmount: floor(balanceValue*100)/100, balanceCurrency: balanceCurrency)
                                        
                                        let guestUID = MMPUseCases.shared.getGuestUID()
                                        let oemID = MMPUseCases.shared.getOEMID()
                                        
                                        // 5. Build the parameters to process the transaction
                                        self.transactionParameters = TransactionParameters(value: String(moneyAmount), currency: product.priceCurrency, domain: domain, product: product.sku, guestUID: guestUID, oemID: oemID, metadata: self.metadata, reference: self.reference)
                                        
                                        // 6. Show loaded view
                                        self.bottomSheetViewModel.setPurchaseState(newState: .paying)
                                    }
                                }
                            } else { self.bottomSheetViewModel.transactionFailedWith(error: .unknown(message: "Failed to build transaction", description: "Missig required parameters: moneyAmount is nil at TransactionViewModel.swift:buildTransaction"))
                            }
                        case .failure(let error):
                            switch error {
                            case .failed(let message, let description, let request):
                                self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                            case .noInternet(let message, let description, let request):
                                self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                            }
                        }
                    }
                case .failure(let error):
                    switch error {
                    case .failed(let message, let description, let request):
                        self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                    case .noInternet(let message, let description, let request):
                        self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                    }
                }
            }
            
        } else { bottomSheetViewModel.transactionFailedWith(error: .systemError(message: "Failed to build transaction", description: "Missing required parameters: product is nil or domain is nil at TransactionViewModel.swift:buildTransaction"))
        }
    }
    
    private func getWalletBalance(wallet: Wallet, completion: @escaping (Balance) -> Void) {
        wallet.getBalance {
            result in
            
            switch result {
            case .success(let balance):
                completion(balance)
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noInternet(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .networkError(message: message, description: description, request: request))
                }
            }
        }
    }
}
