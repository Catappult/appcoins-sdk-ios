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
    
    internal var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    internal var walletUseCases: WalletUseCases = WalletUseCases.shared
    internal var productUseCases: ProductUseCases = ProductUseCases.shared
    internal var bottomSheetViewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    internal var currencyUseCases: CurrencyUseCases = CurrencyUseCases.shared
    
    // Transaction attributes
    internal var product: Product? = nil
    internal var domain: String? = nil
    internal var metadata: String? = nil
    internal var reference: String? = nil
    
    @Published internal var transaction: TransactionAlertUi?
    internal var transactionParameters: TransactionParameters?
    
    // Payment Method choice display variables
    @Published internal var paymentMethodSelected: PaymentMethod?
    @Published internal var showOtherPaymentMethods = false
    @Published internal var lastPaymentMethod: PaymentMethod? = nil
    @Published internal var paypalLogOut = false // Show Log Out from PayPal option on Quick Screen
    internal var hasBonus: Bool {
        if paymentMethodSelected?.name == Method.appc.rawValue {
            return false
        } else if paymentMethodSelected?.name == Method.sandbox.rawValue {
            return false
        } else {
            return true
        }
    }
    
    private init() {}
    
    internal func reset() {
        self.product = nil
        self.domain = nil
        self.metadata = nil
        self.reference = nil
        
        self.transaction = nil
        self.transactionParameters = nil
        
        self.paymentMethodSelected = nil
        self.showOtherPaymentMethods = false
        self.lastPaymentMethod = nil
        self.paypalLogOut = false
    }
    
    // Called when a user starts a product purchase
    internal func setUpTransaction(product: Product, domain: String, metadata: String?, reference: String?) {
        self.product = product
        self.domain = domain
        self.metadata = metadata
        self.reference = reference
    }
    
    internal func buildTransaction() {
        bottomSheetViewModel.setPurchaseState(newState: .paying)
        
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
                            // 3. Get product value
                            self.getProductAppcValue(product: product) {
                                appcValue in
                                
                                if let moneyAmount = Double(product.priceValue) {
                                    // 4. Get user bonus
                                    self.getTransactionBonus(wallet: wallet, domain: domain, amount: product.priceValue, currency: productCurrency) {
                                        transactionBonus in
                                        
                                        // 5. Get payment methods available
                                        self.getPaymentMethods(value: product.priceValue, currency: productCurrency, wallet: wallet, domain: domain) {
                                            availablePaymentMethods in
                                            
                                            // 6. Get user's balance
                                            self.getWalletBalance(wallet: wallet) {
                                                balance in
                                                        
                                                let balanceValue = balance.balance
                                                let balanceCurrency = balance.balanceCurrency
                                                
                                                // 7. Get developer's address
                                                self.getDeveloperAddress(domain: domain) {
                                                    developerWa in
                                                    
                                                    DispatchQueue.main.async {
                                                        // 8. Build the Transaction UI
                                                        self.transaction = TransactionAlertUi(domain: domain, description: product.title, category: .IAP, sku: product.sku, moneyAmount: moneyAmount, moneyCurrency: productCurrency, appcAmount: appcValue, bonusAmount: transactionBonus.value, bonusCurrency: transactionBonus.currency, balanceAmount: balanceValue, balanceCurrency: balanceCurrency, paymentMethods: availablePaymentMethods)
                                                        
                                                        let guestUID = MMPUseCases.shared.getGuestUID()
                                                        let oemID = MMPUseCases.shared.getOEMID()
                                                        
                                                        // 9. Build the parameters to process the transaction
                                                        self.transactionParameters = TransactionParameters(value: String(moneyAmount), currency: product.priceCurrency, developerWa: developerWa, userWa: wallet.getWalletAddress(), domain: domain, product: product.sku, appcAmount: String(appcValue), guestUID: guestUID, oemID: oemID, metadata: self.metadata, reference: self.reference)
                                                        
                                                        // 10. Show payment method options
                                                        self.showPaymentMethodsOnBuild(balance: balance)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else { self.bottomSheetViewModel.transactionFailedWith(error: .unknown) }
                            }
                        case .failure(_):
                            self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                        }
                    }
                case .failure(_):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                }
            }
        } else { bottomSheetViewModel.transactionFailedWith(error: .systemError) }
    }
    
    private func getProductAppcValue(product: Product, completion: @escaping (Double) -> Void) {
        self.productUseCases.getProductAppcValue(product: product) {
            result in
            
            switch result {
            case .success(let appcAmount):
                if let appcAmount = Double(appcAmount) { completion(appcAmount) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError) }
            case .failure(let failure):
                if failure == .noInternet { self.bottomSheetViewModel.transactionFailedWith(error: .networkError) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError) }
            }
        }
    }
    
    private func getTransactionBonus(wallet: Wallet, domain: String, amount: String, currency: Currency, completion: @escaping (TransactionBonus) -> Void) {
        self.transactionUseCases.getTransactionBonus(wallet: wallet, package_name: domain, amount: amount, currency: currency) {
            result in
            switch result {
            case .success(let transactionBonus):
                completion(transactionBonus)
            case .failure(let failure):
                switch failure {
                case .failed(_): self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                case .noInternet: self.bottomSheetViewModel.transactionFailedWith(error: .networkError)
                default: self.bottomSheetViewModel.transactionFailedWith(error: .systemError)
                }
            }
        }
    }
    
    private func getPaymentMethods(value: String, currency: Currency, wallet: Wallet, domain: String, completion: @escaping ([PaymentMethod]) -> Void) {
        self.transactionUseCases.getPaymentMethods(value: value, currency: currency, wallet: wallet, domain: domain) {
            result in
            
            switch result {
            case .success(let paymentMethods):
                var availablePaymentMethods: [PaymentMethod] = []
                for method in paymentMethods {
                    if BuildConfiguration.integratedMethods.map({$0.rawValue}).contains(method.name) {
                        if !availablePaymentMethods.contains(where: { $0.name == Method.appc.rawValue }) {
                            availablePaymentMethods.insert(method, at: 0)
                        } else {
                            availablePaymentMethods.append(method)
                        }
                    }
                }
                completion(availablePaymentMethods)
            case .failure(let failure):
                if failure == .noInternet { self.bottomSheetViewModel.transactionFailedWith(error: .networkError) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError) }
            }
        }
    }
    
    private func getWalletBalance(wallet: Wallet, completion: @escaping (Balance) -> Void) {
        wallet.getBalance {
            result in
            
            switch result {
            case .success(let balance):
                completion(balance)
            case .failure(let failure):
                if failure == .noInternet { self.bottomSheetViewModel.transactionFailedWith(error: .networkError) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError) }
            }
        }
    }
    
    private func getDeveloperAddress(domain: String, completion: @escaping (String) -> Void) {
        self.transactionUseCases.getDeveloperAddress(package: domain) {
            result in
            switch result {
            case .success(let developerWa):
                completion(developerWa)
            case .failure(let failure):
                if failure == .noInternet { self.bottomSheetViewModel.transactionFailedWith(error: .networkError) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError) }
            }
        }
    }
    
    private func showPaymentMethodsOnBuild(balance: Balance) {
        // Filter out the AppCoins payment method if balance is insufficient
        disableAppCoinsIfNeeded(balance: balance)
        
        // Quick view of the last payment method used
        if let lastPaymentMethod = self.transactionUseCases.getLastPaymentMethod() {
            showQuickPaymentMethod(lastPaymentMethod)
        } else {
            selectDefaultPaymentMethod()
        }
        
        func disableAppCoinsIfNeeded(balance: Balance) {
            if balance.appcoinsBalance < self.transaction?.appcAmount ?? 0,
               let index = self.transaction?.paymentMethods.firstIndex(where: { $0.name == Method.appc.rawValue }) {
                if var appcPaymentMethod = self.transaction?.paymentMethods[index] {
                    appcPaymentMethod.disable()
                    self.transaction?.paymentMethods[index] = appcPaymentMethod
                }
            }
        }
        
        func selectDefaultPaymentMethod() {
            if let appcPaymentMethod = self.transaction?.paymentMethods.first(where: { $0.name == Method.appc.rawValue && !$0.disabled }) {
                self.lastPaymentMethod = appcPaymentMethod
                self.paymentMethodSelected = appcPaymentMethod
            } else if let fallback = findFallbackPaymentMethod() {
                self.paymentMethodSelected = fallback
                self.showOtherPaymentMethods = true
            }
        }

        func showQuickPaymentMethod(_ lastPaymentMethod: Method) {
            if let selectedMethod = self.transaction?.paymentMethods.first(where: { $0.name == lastPaymentMethod.rawValue && !$0.disabled }) {
                self.lastPaymentMethod = selectedMethod
                self.paymentMethodSelected = selectedMethod
            } else {
                handleFallbackPaymentMethod(for: lastPaymentMethod)
            }
            
            func handleFallbackPaymentMethod(for method: Method) {
                if let fallback = findFallbackPaymentMethod() {
                    self.paymentMethodSelected = fallback
                }
                
                if method == .paypalDirect, self.transactionUseCases.hasBillingAgreement() {
                    self.paypalLogOut = true
                }
                
                self.showOtherPaymentMethods = true
            }
        }
        
        func findFallbackPaymentMethod() -> PaymentMethod? {
            return self.transaction?.paymentMethods.first(where: {
                $0.name == Method.paypalAdyen.rawValue || $0.name == Method.paypalDirect.rawValue
            }) ?? self.transaction?.paymentMethods.first
        }
    }
    
    internal func showPaymentMethodOptions() { DispatchQueue.main.async { self.showOtherPaymentMethods = true } }
    
    internal func selectPaymentMethod(paymentMethod: PaymentMethod) {
        DispatchQueue.main.async { self.paymentMethodSelected = paymentMethod }
    }
}
