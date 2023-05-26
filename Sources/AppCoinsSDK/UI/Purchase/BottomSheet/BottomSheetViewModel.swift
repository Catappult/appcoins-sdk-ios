//
//  File.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import Foundation
import SwiftUI

class BottomSheetViewModel : ObservableObject {
    
    @Published var purchaseState: PaymentState = .paying
    @Published var transaction: TransactionAlertUi?
    @Published var finalWalletBalance: String?
    @Published var purchaseFailedMessage: String = Constants.somethingWentWrong
    var transactionParameters: CreateTransactionRaw?
    
    private var paymentMethodSelected: Int?
    
    var productUseCases: ProductUseCases = ProductUseCases()
    var transactionUseCases: TransactionUseCases = TransactionUseCases()
    var walletUseCases: WalletUseCases = WalletUseCases()
    
    var dismissVC: () -> Void
    
    var tryAgainProduct: Product? = nil
    var tryAgainDomain: String? = nil
    var tryAgainMetadata: String? = nil
    var tryAgainReference: String? = nil
    
    init(dismiss: @escaping () -> Void) {
        self.dismissVC = dismiss
        
        NotificationCenter.default.addObserver(self, selector: #selector(buildPurchase), name: Notification.Name("APPCBuildPurchase"), object: nil)
    }
    
    @objc func buildPurchase(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("APPCBuildPurchase"), object: nil)
        
        if let userInfo = notification.userInfo {
            if let product = userInfo["product"] as? Product, let domain = userInfo["domain"] as? String, var metadata = userInfo["metadata"] as? String?, var reference = userInfo["reference"] as? String? {
                
                // save request values to reload if needed
                self.tryAgainProduct = product
                self.tryAgainDomain = domain
                self.tryAgainMetadata = metadata
                self.tryAgainReference = reference
                
                buildTransaction(product: product, domain: domain, metadata: metadata, reference: reference)
            }
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
                                        
                                        var uiMethods: [PaymentMethodUi] = []
                                        for method in paymentMethods {
                                            uiMethods.append(PaymentMethodUi(icon: method.icon, label: method.label))
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
                                                    paymentMethods: uiMethods)
                                                
                                                self.transactionUseCases.getDeveloperAddress(package: domain) {
                                                    result in
                                                    
                                                    switch result {
                                                    case .success(let developerWa):
                                                        var transactionMetadata: String? = metadata
                                                        var transactionReference: String? = reference
                                                        if metadata == "" { transactionMetadata = nil }
                                                        if reference == "" { transactionReference = nil }
                                                        
                                                        self.transactionParameters = CreateTransactionRaw.getTransaction(domain: domain, price: String(appcAmount), product: product.sku, developerWa: developerWa, metadata: transactionMetadata, reference: transactionReference)
                                                        
                                                        DispatchQueue.main.async { self.transaction = build }
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
    
    func onPaymentMethodChanged(index: Int) {
        paymentMethodSelected = index
    }
    
    func dismiss() {
        if purchaseState == .paying {
            let result : TransactionResult = .userCancelled
            Utils.transactionResult(result: result)
        }
        self.dismissVC()
    }
    
    
    func buy() {
        DispatchQueue.main.async { self.purchaseState = .processing }
        
        DispatchQueue(label: "buy-item", qos: .userInteractive).async {
            if let wallet = self.walletUseCases.getClientWallet(), let wa = wallet.address, let raw = self.transactionParameters {
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
                                            DispatchQueue.main.async {
                                                self.finalWalletBalance = "\(balance.balanceCurrency)\(String(format: "%.2f", balance.balance))"
                                                self.purchaseState = .success
                                            }
                                            
                                            Purchase.verify(purchaseUID: purchaseUID) {
                                                result in
                                                
                                                switch result {
                                                case .success(let purchase):
                                                    purchase.acknowledge {
                                                        error in
                                                        if let error = error {
                                                            let result : TransactionResult = .failed(error: error)
                                                            Utils.transactionResult(result: result)
                                                        } else {
                                                            let verificationResult: VerificationResult = .verified(purchase: purchase)
                                                            let transactionResult: TransactionResult = .success(verificationResult: verificationResult)
                                                            Utils.transactionResult(result: transactionResult)
                                                        }
                                                    }
                                                case .failure(let error):
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
