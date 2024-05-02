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
            if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
                // 1. Get product value
                getProductAppcValue(product: product) {
                    appcValue in
                    
                    if let moneyAmount = Double(product.priceValue), let productCurrency = Coin(rawValue: product.priceCurrency) {
                        // 2. Get user bonus
                        self.getTransactionBonus(address: wa, domain: domain, amount: product.priceValue, currency: productCurrency) {
                        transactionBonus in
                        
                            // 3. Get payment methods available
                            self.getPaymentMethods(value: product.priceValue, currency: productCurrency) {
                                availablePaymentMethods in

                                // 4. Get user's balance
                                self.getWalletBalance(wallet: wallet, address: wa, currency: Coin(rawValue: product.priceCurrency) ?? .EUR) {
                                    balance in
                                    
                                    let balanceValue = balance.balance
                                    let balanceCurrency = balance.balanceCurrency
                                    
                                    // 5. Get developer's address
                                    self.getDeveloperAddress(domain: domain) {
                                        developerWa in
                                        
                                        DispatchQueue.main.async {
                                            // 6. Build the Transaction UI
                                            self.transaction = TransactionAlertUi(domain: domain, description: product.title, category: .IAP, sku: product.sku, moneyAmount: moneyAmount, moneyCurrency: product.priceCurrency, appcAmount: appcValue, bonusCurrency: transactionBonus.currency.symbol, bonusAmount: transactionBonus.value, walletBalance: "\(balanceCurrency)\(String(format: "%.2f", balanceValue))", paymentMethods: availablePaymentMethods)
                                            
                                            // 7. Build the parameters to process the transaction
                                            self.transactionParameters = TransactionParameters(value: String(moneyAmount), currency: Coin.EUR.rawValue, developerWa: developerWa, userWa: wa, domain: domain, product: product.sku, appcAmount: String(appcValue), metadata: self.metadata, reference: self.reference)
                                            
                                            // 8. Show payment method options
                                            self.showPaymentMethodsOnBuild(balance: balance)
                                        }
                                    }
                                }
                            }
                        }
                    } else { self.bottomSheetViewModel.transactionFailedWith(error: .unknown) }
                }
            } else { bottomSheetViewModel.transactionFailedWith(error: .notEntitled) }
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

    private func getTransactionBonus(address: String, domain: String, amount: String, currency: Coin, completion: @escaping (TransactionBonus) -> Void) {
        self.transactionUseCases.getTransactionBonus(address: address, package_name: domain, amount: amount, currency: currency) {
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
    
    private func getPaymentMethods(value: String, currency: Coin, completion: @escaping ([PaymentMethod]) -> Void) {
        self.transactionUseCases.getPaymentMethods(value: value, currency: currency) {
            result in
            
            switch result {
            case .success(let paymentMethods):
                var availablePaymentMethods: [PaymentMethod] = []
                for method in paymentMethods {
                    if BuildConfiguration.integratedMethods.map({$0.rawValue}).contains(method.name) { availablePaymentMethods.append(method) }
                }
                completion(availablePaymentMethods)
            case .failure(let failure):
                if failure == .noInternet { self.bottomSheetViewModel.transactionFailedWith(error: .networkError) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError) }
            }
        }
    }
    
    private func getWalletBalance(wallet: Wallet, address: String, currency: Coin, completion: @escaping (Balance) -> Void) {
        wallet.getBalance(wa: address, currency: currency) {
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
        if let selected = self.transaction?.paymentMethods.first { self.paymentMethodSelected = selected }
        
        // Other Payment Methods filtering
        if balance.appcoinsBalance < self.transaction?.appcAmount ?? 0 {
            if let index = self.transaction?.paymentMethods.firstIndex(where: { $0.name == Method.appc.rawValue }) {
                if var appcPM = self.transaction?.paymentMethods.remove(at: index) {
                    appcPM.disabled = true
                    self.transaction?.paymentMethods.append(appcPM)
                    if let selected = self.transaction?.paymentMethods.first { self.paymentMethodSelected = selected }
                }
            }
        }
        
        // Quick view of last payment method used
        let lastPaymentMethod = self.transactionUseCases.getLastPaymentMethod()
        if let lastPaymentMethod = lastPaymentMethod {
            switch lastPaymentMethod {
            case Method.appc:
                if let appcPM = self.transaction?.paymentMethods.first(where: { $0.name == Method.appc.rawValue && $0.disabled == false }) {
                    self.lastPaymentMethod = appcPM
                    self.paymentMethodSelected = appcPM
                } else {
                    self.showOtherPaymentMethods = true
                }
            case Method.paypalAdyen:
                if let paypalPM = self.transaction?.paymentMethods.first(where: { $0.name == Method.paypalAdyen.rawValue }) {
                    self.lastPaymentMethod = paypalPM
                    self.paymentMethodSelected = paypalPM
                } else {
                    self.showOtherPaymentMethods = true
                }
            case Method.paypalDirect:
                if let paypalPM = self.transaction?.paymentMethods.first(where: { $0.name == Method.paypalDirect.rawValue }) {
                    if self.transactionUseCases.hasBillingAgreement() { self.paypalLogOut = true }
                    self.lastPaymentMethod = paypalPM
                    self.paymentMethodSelected = paypalPM
                } else {
                    self.showOtherPaymentMethods = true
                }
            case Method.creditCard:
                if let ccPM = self.transaction?.paymentMethods.first(where: { $0.name == Method.creditCard.rawValue }) {
                    self.lastPaymentMethod = ccPM
                    self.paymentMethodSelected = ccPM
                } else {
                    self.showOtherPaymentMethods = true
                }
            default:
                self.showOtherPaymentMethods = true
            }
        } else {
            if let appcPM = self.transaction?.paymentMethods.first(where: { $0.name == Method.appc.rawValue && $0.disabled == false }) {
                self.lastPaymentMethod = appcPM
                self.paymentMethodSelected = appcPM
            } else {
                self.showOtherPaymentMethods = true
            }
        }
    }
    
    internal func showPaymentMethodOptions() { DispatchQueue.main.async { self.showOtherPaymentMethods = true } }
    
    internal func selectPaymentMethod(paymentMethod: PaymentMethod) { DispatchQueue.main.async { self.paymentMethodSelected = paymentMethod } }
}
