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
    
    // Show Log Out from PayPal option on Selected Payment Method Banner
    @Published internal var isPaypalLogOutPresented = false
    @Published internal var isPaypalLogOutLoadingPresented = false
    
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
        
        self.isPaypalLogOutPresented = false
        self.isPaypalLogOutLoadingPresented = false
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
                            AuthViewModel.shared.setLogInState(isLoggedIn: wallet is UserWallet)
                            
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
                                                
                                                DispatchQueue.main.async {
                                                    // 7. Build the Transaction UI
                                                    self.transaction = TransactionAlertUi(domain: domain, description: product.title, category: .IAP, sku: product.sku, moneyAmount: moneyAmount, moneyCurrency: productCurrency, appcAmount: appcValue, bonusAmount: floor(transactionBonus.value*100)/100, bonusCurrency: transactionBonus.currency, balanceAmount: floor(balanceValue*100)/100, balanceCurrency: balanceCurrency, paymentMethods: availablePaymentMethods)
                                                    
                                                    let guestUID = MMPUseCases.shared.getGuestUID()
                                                    let oemID = MMPUseCases.shared.getOEMID()
                                                    
                                                    // 8. Build the parameters to process the transaction
                                                    self.transactionParameters = TransactionParameters(value: String(moneyAmount), currency: product.priceCurrency, domain: domain, product: product.sku, appcAmount: String(appcValue), guestUID: guestUID, oemID: oemID, metadata: self.metadata, reference: self.reference)
                                                    
                                                    // 9. Show payment method options
                                                    self.showPaymentMethodsOnBuild(wallet: wallet, balance: balance)
                                                    
                                                    // 10. Show loaded view
                                                    self.bottomSheetViewModel.setPurchaseState(newState: .paying)
                                                }
                                            }
                                        }
                                    }
                                } else { self.bottomSheetViewModel.transactionFailedWith(error: .unknown(message: "Failed to build transaction", description: "Missig required parameters: moneyAmount is nil at TransactionViewModel.swift:buildTransaction")) }
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
        } else { bottomSheetViewModel.transactionFailedWith(error: .systemError(message: "Failed to build transaction", description: "Missing required parameters: product is nil or domain is nil at TransactionViewModel.swift:buildTransaction")) }
    }
    
    private func getProductAppcValue(product: Product, completion: @escaping (Double) -> Void) {
        self.productUseCases.getProductAppcValue(product: product) {
            result in
            
            switch result {
            case .success(let appcAmount):
                if let appcAmount = Double(appcAmount) { completion(floor(appcAmount * 100) / 100) }
                else { self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: "Failed to get product appc value", description: "Missing required parameters: AppCoins amount is nil at TransactionViewModel.swift:getProductAppcValue")) }
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
    
    private func getTransactionBonus(wallet: Wallet, domain: String, amount: String, currency: Currency, completion: @escaping (TransactionBonus) -> Void) {
        self.transactionUseCases.getTransactionBonus(wallet: wallet, package_name: domain, amount: amount, currency: currency) {
            result in
            switch result {
            case .success(let transactionBonus):
                completion(transactionBonus)
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .general(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noBillingAgreement(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
                case .noInternet(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .networkError(message: message, description: description, request: request))
                case .timeOut(let message, let description, let request):
                    self.bottomSheetViewModel.transactionFailedWith(error: .systemError(message: message, description: description, request: request))
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
    
    private func showPaymentMethodsOnBuild(wallet: Wallet, balance: Balance) {
        // Filter out the AppCoins payment method if balance is insufficient
        disableAppCoinsIfNeeded(balance: balance)
        
        // Quick view of the last payment method used
        if let lastPaymentMethod = self.transactionUseCases.getLastPaymentMethod() {
            showQuickPaymentMethod(wallet: wallet, lastPaymentMethod: lastPaymentMethod)
        } else {
            self.showOtherPaymentMethods = true
        }
        
        func disableAppCoinsIfNeeded(balance: Balance) {
            guard let index = self.transaction?.paymentMethods.firstIndex(where: { $0.name == Method.appc.rawValue }) else {
                return
            }
            
            guard var APPC: PaymentMethod = self.transaction?.paymentMethods[index] else {
                return
            }
            
            let hasEnoughBalance: Bool = balance.appcoinsBalance >= self.transaction?.appcAmount ?? 0
            let isLoggedIn: Bool = AuthViewModel.shared.isLoggedIn
            
            if !hasEnoughBalance || !isLoggedIn {
                APPC.disable()
                self.transaction?.paymentMethods[index] = APPC
            }
        }
        
        func showQuickPaymentMethod(wallet: Wallet, lastPaymentMethod: Method) {
            if let selectedMethod = self.transaction?.paymentMethods.first(where: { $0.name == lastPaymentMethod.rawValue && !$0.disabled }) {
                self.lastPaymentMethod = selectedMethod
                self.paymentMethodSelected = selectedMethod
                
                if selectedMethod.name == Method.paypalDirect.rawValue, self.transactionUseCases.hasBillingAgreement(wallet: wallet) {
                    self.presentPayPalLogoutOption()
                } else {
                    self.hidePayPalLogOutOption()
                }
            } else {
                handleFallbackPaymentMethod(for: lastPaymentMethod, wallet: wallet)
            }
            
            func handleFallbackPaymentMethod(for method: Method, wallet: Wallet) {
                if let fallback = findFallbackPaymentMethod() {
                    self.paymentMethodSelected = fallback
                }
                
                if method == .paypalDirect, self.transactionUseCases.hasBillingAgreement(wallet: wallet) {
                    self.presentPayPalLogoutOption()
                } else {
                    self.hidePayPalLogOutOption()
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
    
    internal func transferBonusOnLogin(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        guard let clientWallet: Wallet = walletUseCases.getClientWallet() else {
            completion(.failure(.failed(message: "Failed to transfer bonus on Login", description: "Missing Client Wallet transferring bonus from Client Wallet to User Wallet after Login at TransactionViewModel.swift:transferBonusOnLogin")))
            return
        }
        
        guard let transaction: TransactionAlertUi = self.transaction else {
            completion(.failure(.failed(message: "Failed to transfer bonus on Login", description: "Missing active transaction transferring bonus from Client Wallet to User Wallet after Login at TransactionViewModel.swift:transferBonusOnLogin")))
            return
        }
        
        let amount: String = String(transaction.bonusAmount).replacingOccurrences(of: ",", with: ".")
        let currency: String = transaction.bonusCurrency.currency
            
        walletUseCases.getWallet() { result in
            switch result {
            case .success(let userWallet):
                if userWallet is UserWallet {
                    let raw: TransferAPPCRaw = TransferAPPCRaw.from(price: amount, currency: currency, userWa: userWallet.getWalletAddress())
                    self.transactionUseCases.transferAPPC(wa: clientWallet, raw: raw) { result in
                        switch result {
                        case .success(_):
                            completion(.success(true))
                        case .failure(let failure):
                            completion(.failure(failure))
                        }
                    }
                }
            case .failure(let failure):
                switch failure {
                case .failed(let message, let description, let request): completion(.failure(.failed(message: message, description: description, request: request)))
                case .noInternet(let message, let description, let request): completion(.failure(.noInternet(message: message, description: description, request: request)))
                }
            }
        }
    }
    
    internal func presentPayPalLogoutOption() {
        DispatchQueue.main.async {
            self.isPaypalLogOutPresented = true
            self.isPaypalLogOutLoadingPresented = false
        }
    }
    
    internal func presentPayPalLogoutLoading() {
        DispatchQueue.main.async {
            self.isPaypalLogOutPresented = false
            self.isPaypalLogOutLoadingPresented = true
        }
    }
    
    internal func hidePayPalLogOutOption() {
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.isPaypalLogOutPresented = false
                self.isPaypalLogOutLoadingPresented = false
            }
        }
    }
}
