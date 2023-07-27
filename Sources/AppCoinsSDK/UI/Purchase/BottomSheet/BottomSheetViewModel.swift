//
//  File.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI

class BottomSheetViewModel : ObservableObject {
    
    static var shared : BottomSheetViewModel = BottomSheetViewModel()
    
    @Published var purchaseState: PaymentState = .paying
    @Published var dismissingSuccess: Bool = false
    @Published var transaction: TransactionAlertUi?
    @Published var finalWalletBalance: String?
    @Published var purchaseFailedMessage: String = Constants.somethingWentWrong
    var transactionParameters: [String : String] = [:]
    
    @Published var paymentMethodSelected: PaymentMethod?
    
    // Last Payment Method for initial transaction screen
    @Published var showOtherPaymentMethods = false
    @Published var lastPaymentMethod: PaymentMethod? = nil
    // Show Log Out from PayPal option on Quick Screen
    @Published var paypalLogOut = false
    
    // PayPal Variables
    @Published var presentPayPalSheet : Bool = false
    @Published var presentPayPalSheetURL : URL? = nil
    @Published var presentPayPalSheetMethod : String? = nil
    @Published var userDismissPayPalSheet : Bool = true
    
    var productUseCases: ProductUseCases = ProductUseCases.shared
    var transactionUseCases: TransactionUseCases = TransactionUseCases.shared
    var walletUseCases: WalletUseCases = WalletUseCases.shared
        
    var tryAgainProduct: Product? = nil
    var tryAgainDomain: String? = nil
    var tryAgainMetadata: String? = nil
    var tryAgainReference: String? = nil
    
    var hasActiveTransaction = false
    
    private init() {
        // Prevents Layout Warning Prints
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
    
    func dismissVC() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
           let presentedPurchaseVC = rootViewController.presentedViewController as? PurchaseViewController {
            
            DispatchQueue.main.async {
                presentedPurchaseVC.dismissPurchase()
                self.hasActiveTransaction = false
                self.reset()
            }
        }
    }
    
    private func reset() {
        self.purchaseState = .paying
        self.dismissingSuccess = false
        self.transaction = nil
        self.finalWalletBalance = nil
        self.transactionParameters = [:]
        
        self.paymentMethodSelected = nil

        self.showOtherPaymentMethods = false
        self.lastPaymentMethod = nil
        self.paypalLogOut = false
        
        self.presentPayPalSheet = false
        self.presentPayPalSheetURL = nil
        self.presentPayPalSheetMethod = nil
        self.userDismissPayPalSheet = true

        self.tryAgainProduct = nil
        self.tryAgainDomain = nil
        self.tryAgainMetadata = nil
        self.tryAgainReference = nil
    }
    
    func buildPurchase(product: Product, domain: String, metadata: String?, reference: String?) {
        // save request values to reload if needed
        self.tryAgainProduct = product
        self.tryAgainDomain = domain
        self.tryAgainMetadata = metadata
        self.tryAgainReference = reference
        self.hasActiveTransaction = true
        
        DispatchQueue(label: "build-transaction", qos: .userInteractive).async {
            self.buildTransaction(product: product, domain: domain, metadata: metadata, reference: reference)
        }
    }
    
    func reload() {
        if let product = tryAgainProduct, let domain = tryAgainDomain {
            let metadata = tryAgainMetadata
            let reference = tryAgainReference
            DispatchQueue.main.async { self.purchaseState = .paying }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.buildTransaction(product: product, domain: domain, metadata: metadata, reference: reference)
            }
        }
    }
    
    func buildTransaction(product: Product, domain: String, metadata: String?, reference: String?) {
        if let wallet = walletUseCases.getClientWallet(), let wa = wallet.address {
            self.productUseCases.getProductAppcValue(product: product) {
                result in
                
                switch result {
                case .success(let appcAmount):
                    
                    if let appcAmount = Double(appcAmount), let moneyAmount = Double(product.priceValue), let address = wallet.address, let productCurrency = Coin(rawValue: product.priceCurrency) {
                        
                        self.transactionUseCases.getTransactionBonus(address: address, package_name: domain, amount: product.priceValue, currency: productCurrency) {
                            result in
                            
                            switch result {
                            case .success(let transactionBonus):
                                
                                self.transactionUseCases.getPaymentMethods(value: product.priceValue, currency: productCurrency) {
                                    result in
                                    
                                    switch result {
                                    case .success(let paymentMethods):
                                        
                                        var availablePaymentMethods: [PaymentMethod] = []
                                        for method in paymentMethods {
                                            if ["appcoins_credits", "paypal", "paypal_v2"].contains(method.name) { availablePaymentMethods.append(method) }
                                        }
                                        
                                        wallet.getBalance(wa: wa, currency: Coin(rawValue: product.priceCurrency) ?? .EUR) {
                                            result in
                                            
                                            switch result {
                                            case .success(let balance):
                                                let balanceValue = balance.balance
                                                let balanceCurrency = balance.balanceCurrency
                                                
                                                let build = TransactionAlertUi(
                                                    domain: domain,
                                                    description: product.title,
                                                    category: .IAP,
                                                    sku: product.sku,
                                                    moneyAmount: moneyAmount,
                                                    moneyCurrency: product.priceCurrency,
                                                    appcAmount: appcAmount,
                                                    bonusCurrency: transactionBonus.currency.symbol,
                                                    bonusAmount: transactionBonus.value,
                                                    walletBalance: "\(balanceCurrency)\(String(format: "%.2f", balanceValue))",
                                                    paymentMethods: availablePaymentMethods)
                                                
                                                self.transactionUseCases.getDeveloperAddress(package: domain) {
                                                    result in
                                                    
                                                    switch result {
                                                    case .success(let developerWa):
                                                        var transactionMetadata: String? = metadata
                                                        var transactionReference: String? = reference
                                                        if metadata == "" { transactionMetadata = nil }
                                                        if reference == "" { transactionReference = nil }
                                                        
                                                        self.transactionParameters = [
                                                            "value": String(moneyAmount),
                                                            "currency": "EUR",
                                                            "developerWa": developerWa,
                                                            "userWa": wa,
                                                            "domain": domain,
                                                            "product": product.sku,
                                                            "appcAmount": String(appcAmount),
                                                            "metadata": transactionMetadata ?? "",
                                                            "reference": transactionReference ?? ""
                                                         ]
                                                            
                                                        DispatchQueue.main.async {
                                                            self.transaction = build
                                                            
                                                            if let selected = self.transaction?.paymentMethods.first { self.paymentMethodSelected = selected }
                                                            
                                                            // Other Payment Methods filtering
                                                            if balance.appcoinsBalance < self.transaction?.appcAmount ?? 0 {
                                                                if let index = self.transaction?.paymentMethods.firstIndex(where: { $0.name == "appcoins_credits" }) {
                                                                    if var appcPM = self.transaction?.paymentMethods.remove(at: index) {
                                                                        appcPM.disabled = true
                                                                        self.transaction?.paymentMethods.append(appcPM)
                                                                        if let selected = self.transaction?.paymentMethods.first { self.paymentMethodSelected = selected }
                                                                    }
                                                                }
                                                            }
                                                            
                                                            // Quick view of last payment method used
                                                            let lastPaymentMethod = self.transactionUseCases.getLastPaymentMethod()
                                                            if lastPaymentMethod != "" {
                                                                switch lastPaymentMethod {
                                                                case "appcoins_credits":
                                                                    if let appcPM = self.transaction?.paymentMethods.first(where: { $0.name == "appcoins_credits" && $0.disabled == false }) {
                                                                        self.lastPaymentMethod = appcPM
                                                                        self.paymentMethodSelected = appcPM
                                                                    } else {
                                                                        self.showOtherPaymentMethods = true
                                                                    }
                                                                case "paypal":
                                                                    if let paypalPM = self.transaction?.paymentMethods.first(where: { $0.name == "paypal" || $0.name == "paypal_v2" }) {
                                                                        if self.transactionUseCases.hasBillingAgreement() { self.paypalLogOut = true }
                                                                        self.lastPaymentMethod = paypalPM
                                                                        self.paymentMethodSelected = paypalPM
                                                                    } else {
                                                                        self.showOtherPaymentMethods = true
                                                                    }
                                                                default:
                                                                    self.showOtherPaymentMethods = true
                                                                }
                                                            } else {
                                                                if let appcPM = self.transaction?.paymentMethods.first(where: { $0.name == "appcoins_credits" && $0.disabled == false }) {
                                                                    self.lastPaymentMethod = appcPM
                                                                    self.paymentMethodSelected = appcPM
                                                                } else {
                                                                    self.showOtherPaymentMethods = true
                                                                }
                                                            }
                                                        }
                                                    case .failure(let failure):
                                                        if failure == .noInternet {
                                                            let result : TransactionResult = .failed(error: .networkError)
                                                            Utils.transactionResult(result: result)
                                                            DispatchQueue.main.async { self.purchaseState = .nointernet }
                                                        } else {
                                                            let result : TransactionResult = .failed(error: .systemError)
                                                            Utils.transactionResult(result: result)
                                                            DispatchQueue.main.async { self.purchaseState = .failed }
                                                        }
                                                    }
                                                }
                                                
                                            case .failure(let failure):
                                                if failure == .noInternet {
                                                    let result : TransactionResult = .failed(error: .networkError)
                                                    Utils.transactionResult(result: result)
                                                    DispatchQueue.main.async { self.purchaseState = .nointernet }
                                                } else {
                                                    let result : TransactionResult = .failed(error: .systemError)
                                                    Utils.transactionResult(result: result)
                                                    DispatchQueue.main.async { self.purchaseState = .failed }
                                                }
                                            }
                                        }
                                    case .failure(let failure):
                                        if failure == .noInternet {
                                            let result : TransactionResult = .failed(error: .networkError)
                                            Utils.transactionResult(result: result)
                                            DispatchQueue.main.async { self.purchaseState = .nointernet }
                                        } else {
                                            let result : TransactionResult = .failed(error: .systemError)
                                            Utils.transactionResult(result: result)
                                            DispatchQueue.main.async { self.purchaseState = .failed }
                                        }
                                    }
                                }
                                
                            case .failure(let failure):
                                switch failure {
                                case .failed(_):
                                    let result : TransactionResult = .failed(error: .systemError)
                                    Utils.transactionResult(result: result)
                                    DispatchQueue.main.async { self.purchaseState = .failed }
                                case .noInternet:
                                    let result : TransactionResult = .failed(error: .networkError)
                                    Utils.transactionResult(result: result)
                                    DispatchQueue.main.async { self.purchaseState = .nointernet }
                                default:
                                    let result : TransactionResult = .failed(error: .systemError)
                                    Utils.transactionResult(result: result)
                                    DispatchQueue.main.async { self.purchaseState = .failed }
                                }
                            }
                        }
                    } else {
                        let result : TransactionResult = .failed(error: .unknown)
                        Utils.transactionResult(result: result)
                        DispatchQueue.main.async { self.purchaseState = .failed }
                    }
                case .failure(let failure):
                    if failure == .noInternet {
                        let result : TransactionResult = .failed(error: .networkError)
                        Utils.transactionResult(result: result)
                        DispatchQueue.main.async { self.purchaseState = .nointernet }
                    } else {
                        let result : TransactionResult = .failed(error: .systemError)
                        Utils.transactionResult(result: result)
                        DispatchQueue.main.async { self.purchaseState = .failed }
                    }
                }
            }
        } else {
            let result : TransactionResult = .failed(error: .notEntitled)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .failed }
        }
    }
    
    func dismiss() {
        if purchaseState == .paying {
            let result : TransactionResult = .userCancelled
            Utils.transactionResult(result: result)
        }
        self.dismissVC()
    }
    
    func logoutPayPal() {
        DispatchQueue.main.async { self.showOtherPaymentMethods = true }
        DispatchQueue(label: "logout-paypal", qos: .userInteractive).async {
            self.transactionUseCases.cancelBillingAgreement() { result in }
        }
    }
    
    func showPaymentMethodOptions() {
        DispatchQueue.main.async { self.showOtherPaymentMethods = true }
    }
    
    func selectPaymentMethod(paymentMethod: PaymentMethod) {
        DispatchQueue.main.async { self.paymentMethodSelected = paymentMethod }
    }
    
    func buy() {
        DispatchQueue.main.async { self.purchaseState = .processing }
        
        DispatchQueue(label: "buy-item", qos: .userInteractive).async {
            if self.paymentMethodSelected?.name == "appcoins_credits" {
                 self.buyWithAppc()
            } else if ["paypal", "paypal_v2"].contains(self.paymentMethodSelected?.name) {
                 self.buyWithPayPal()
            } else {
                let result : TransactionResult = .failed(error: .systemError)
                Utils.transactionResult(result: result)
                DispatchQueue.main.async { self.purchaseState = .failed }
            }
        
        }
    }
    
    func buyWithAppc() {
        let raw = CreateAPPCTransactionRaw.fromDictionary(dictionary: self.transactionParameters)
        if let wallet = self.walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            
            self.transactionUseCases.createTransaction(wa: wa, waSignature: waSignature, raw: raw) {
                result in
                
                switch result {
                case .success(let transactionResponse):
                    self.transactionUseCases.getTransactionInfo(uid: transactionResponse.uuid, wa: wa, waSignature: waSignature) {
                        result in
                        
                        switch result {
                        case .success(let transaction):
                            if let purchaseUID = transaction.purchaseUID {
                                wallet.getBalance(wa: wa, currency: Coin(rawValue: self.transaction?.moneyCurrency ?? "") ?? .EUR) {
                                    result in
                                    
                                    switch result {
                                    case .success(let balance):
                                        Purchase.verify(purchaseUID: purchaseUID) {
                                            result in
                                            
                                            switch result {
                                            case .success(let purchase):
                                                purchase.acknowledge() {
                                                    error in
                                                    if let error = error {
                                                        DispatchQueue.main.async { self.purchaseState = .failed }
                                                        
                                                        let result : TransactionResult = .failed(error: error)
                                                        Utils.transactionResult(result: result)
                                                    } else {
                                                        DispatchQueue.main.async {
                                                            self.finalWalletBalance = "\(balance.balanceCurrency)\(String(format: "%.2f", balance.balance))"
                                                            self.purchaseState = .success
                                                        }
                                                        
                                                        let verificationResult: VerificationResult = .verified(purchase: purchase)
                                                        let transactionResult: TransactionResult = .success(verificationResult: verificationResult)
                                                        Utils.transactionResult(result: transactionResult)
                                                        
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                            self.dismiss()
                                                            withAnimation { self.dismissingSuccess = true }
                                                        }
                                                    }
                                                }
                                            case .failure(let error):
                                                DispatchQueue.main.async { self.purchaseState = .failed }
                                                
                                                let result : TransactionResult = .failed(error: error)
                                                Utils.transactionResult(result: result)
                                            }
                                        }
                                    case .failure(let failure):
                                        if failure == .noInternet {
                                            let result : TransactionResult = .failed(error: .networkError)
                                            Utils.transactionResult(result: result)
                                        } else {
                                            let result : TransactionResult = .failed(error: .systemError)
                                            Utils.transactionResult(result: result)
                                        }
                                        DispatchQueue.main.async { self.purchaseState = .failed }
                                    }
                                }
                            } else {
                                let result : TransactionResult = .failed(error: .systemError)
                                Utils.transactionResult(result: result)
                                DispatchQueue.main.async { self.purchaseState = .failed }
                            }
                        case .failure(let failure):
                            switch failure {
                            case .failed(_):
                                let result : TransactionResult = .failed(error: .systemError)
                                Utils.transactionResult(result: result)
                            case .noInternet:
                                let result : TransactionResult = .failed(error: .networkError)
                                Utils.transactionResult(result: result)
                            default:
                                let result : TransactionResult = .failed(error: .systemError)
                                Utils.transactionResult(result: result)
                            }
                            DispatchQueue.main.async { self.purchaseState = .failed }
                        }
                    }
                case .failure(let failure):
                    switch failure {
                    case .failed(let description):
                        if let description = description { DispatchQueue.main.async { self.purchaseFailedMessage = description } }
                        let result : TransactionResult = .failed(error: .systemError)
                        Utils.transactionResult(result: result)
                    case .noInternet:
                        let result : TransactionResult = .failed(error: .networkError)
                        Utils.transactionResult(result: result)
                    default:
                        let result : TransactionResult = .failed(error: .systemError)
                        Utils.transactionResult(result: result)
                    }
                    DispatchQueue.main.async { self.purchaseState = .failed }
                }
            }
        } else {
            let result : TransactionResult = .failed(error: .notEntitled)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .failed }
        }
    }
    
    func buyWithPayPal() {
        let raw = CreateBAPayPalTransactionRaw.fromDictionary(dictionary: self.transactionParameters)
        if let wallet = self.walletUseCases.getClientWallet(), let wa = wallet.address {
            let waSignature = wallet.getSignedWalletAddress()
            
            self.transactionUseCases.createBAPayPalTransaction(wa: wa, waSignature: waSignature, raw: raw) {
                result in
                
                switch result {
                case .success(let transactionResponse):
                    self.transactionUseCases.getTransactionInfo(uid: transactionResponse.uuid, wa: wa, waSignature: waSignature) {
                        result in
                        
                        switch result {
                        case .success(let transaction):
                            if let purchaseUID = transaction.purchaseUID {
                                wallet.getBalance(wa: wa, currency: Coin(rawValue: self.transaction?.moneyCurrency ?? "") ?? .EUR) {
                                    result in
                                    
                                    switch result {
                                    case .success(let balance):
                                        Purchase.verify(purchaseUID: purchaseUID) {
                                            result in
                                            
                                            switch result {
                                            case .success(let purchase):
                                                purchase.acknowledge() {
                                                    error in
                                                    if let error = error {
                                                        DispatchQueue.main.async { self.purchaseState = .failed }
                                                        
                                                        let result : TransactionResult = .failed(error: error)
                                                        Utils.transactionResult(result: result)
                                                    } else {
                                                        DispatchQueue.main.async {
                                                            self.finalWalletBalance = "\(balance.balanceCurrency)\(String(format: "%.2f", balance.balance))"
                                                            self.purchaseState = .success
                                                        }
                                                        
                                                        let verificationResult: VerificationResult = .verified(purchase: purchase)
                                                        let transactionResult: TransactionResult = .success(verificationResult: verificationResult)
                                                        Utils.transactionResult(result: transactionResult)
                                                        
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                            self.dismiss()
                                                            withAnimation { self.dismissingSuccess = true }
                                                        }
                                                    }
                                                }
                                            case .failure(let error):
                                                DispatchQueue.main.async { self.purchaseState = .failed }
                                                
                                                let result : TransactionResult = .failed(error: error)
                                                Utils.transactionResult(result: result)
                                            }
                                        }
                                    case .failure(let failure):
                                        if failure == .noInternet {
                                            let result : TransactionResult = .failed(error: .networkError)
                                            Utils.transactionResult(result: result)
                                        } else {
                                            let result : TransactionResult = .failed(error: .systemError)
                                            Utils.transactionResult(result: result)
                                        }
                                        DispatchQueue.main.async { self.purchaseState = .failed }
                                    }
                                }
                            } else {
                                let result : TransactionResult = .failed(error: .systemError)
                                Utils.transactionResult(result: result)
                                DispatchQueue.main.async { self.purchaseState = .failed }
                            }
                        case .failure(let failure):
                            switch failure {
                            case .failed(_):
                                let result : TransactionResult = .failed(error: .systemError)
                                Utils.transactionResult(result: result)
                            case .noInternet:
                                let result : TransactionResult = .failed(error: .networkError)
                                Utils.transactionResult(result: result)
                            default:
                                let result : TransactionResult = .failed(error: .systemError)
                                Utils.transactionResult(result: result)
                            }
                            DispatchQueue.main.async { self.purchaseState = .failed }
                        }
                    }
                case .failure(let error):
                    switch error {
                    case .noBillingAgreement:
                        self.transactionUseCases.createBillingAgreementToken() {
                            result in
                            
                            switch result {
                            case .success(let response):
                                if let redirectURL = URL(string: response.redirect.url) {
                                    DispatchQueue.main.async {
                                        self.presentPayPalSheetURL = redirectURL
                                        self.presentPayPalSheetMethod = response.redirect.method
                                        self.presentPayPalSheet = true
                                        self.userDismissPayPalSheet = true
                                    }
                                }
                            case .failure(let error):
                                switch error {
                                case .noInternet:
                                    let result : TransactionResult = .failed(error: .networkError)
                                    Utils.transactionResult(result: result)
                                default:
                                    let result : TransactionResult = .failed(error: .systemError)
                                    Utils.transactionResult(result: result)
                                }
                            }
                        }
                    case .failed(let description):
                        if let description = description { DispatchQueue.main.async { self.purchaseFailedMessage = description } }
                        let result : TransactionResult = .failed(error: .systemError)
                        Utils.transactionResult(result: result)
                        DispatchQueue.main.async { self.purchaseState = .failed }
                    case .noInternet:
                        let result : TransactionResult = .failed(error: .networkError)
                        Utils.transactionResult(result: result)
                        DispatchQueue.main.async { self.purchaseState = .failed }
                    default:
                        let result : TransactionResult = .failed(error: .systemError)
                        Utils.transactionResult(result: result)
                        DispatchQueue.main.async { self.purchaseState = .failed }
                    }
                }
            }
        } else {
            let result : TransactionResult = .failed(error: .notEntitled)
            Utils.transactionResult(result: result)
            DispatchQueue.main.async { self.purchaseState = .failed }
        }
    }
    
    func dismissPayPalView() {
        // only apply when it is the user dismissing the view
        if self.userDismissPayPalSheet {
            DispatchQueue.main.async {
                self.presentPayPalSheet = false
                let result : TransactionResult = .userCancelled
                Utils.transactionResult(result: result)
                self.dismissVC()
            }
        }
    }
    
    func cancelBillingAgreementTokenPayPal(token: String?) {
        DispatchQueue.main.async {
            self.userDismissPayPalSheet = false
            self.presentPayPalSheet = false
        }
        
        if let token = token {
            self.transactionUseCases.cancelBillingAgreementToken(token: token) {
                result in
                DispatchQueue.main.async {
                    self.presentPayPalSheet = false
                    let result : TransactionResult = .userCancelled
                    Utils.transactionResult(result: result)
                    self.dismissVC()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.presentPayPalSheet = false
                let result : TransactionResult = .userCancelled
                Utils.transactionResult(result: result)
                self.dismissVC()
            }
        }
    }
    
    func createBillingAgreementAndFinishTransaction(token: String) {
        DispatchQueue.main.async {
            self.userDismissPayPalSheet = false
            self.presentPayPalSheet = false
        }
        
        self.transactionUseCases.createBillingAgreement(token: token) {
            result in
            
            switch result {
            case .success(_):
                self.buyWithPayPal()
            case .failure(let error):
                switch error {
                case .failed(_):
                    let result : TransactionResult = .failed(error: .systemError)
                    Utils.transactionResult(result: result)
                case .noInternet:
                    let result : TransactionResult = .failed(error: .networkError)
                    Utils.transactionResult(result: result)
                default:
                    let result : TransactionResult = .failed(error: .systemError)
                    Utils.transactionResult(result: result)
                }
                DispatchQueue.main.async { self.purchaseState = .failed }
            }
        }
    }
    
    func getAppIcon() -> UIImage {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {

            return UIImage(named: lastIcon) ?? UIImage()
        }
        return UIImage()
    }
}
