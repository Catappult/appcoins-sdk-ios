//
//  TransactionRepository.swift
//
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
import SwiftyRSA

internal class TransactionRepository: TransactionRepositoryProtocol {
    
    private let gamificationService: AppCoinGamificationService = AppCoinGamificationServiceClient()
    private let billingService: AppCoinBillingService = AppCoinBillingClient()
    private let aptoideService: AptoideService = AptoideServiceClient()
    private let productService: AppCoinProductService = AppCoinProductServiceClient()
    private let walletService: WalletLocalService = WalletLocalClient()
    private let userPreferencesService: UserPreferencesLocalService = UserPreferencesLocalClient()
    
    internal func getTransactionBonus(address: String, package_name: String, amount: String, currency: String, completion: @escaping (Result<TransactionBonus, TransactionError>) -> Void) {
        gamificationService.getTransactionBonus(address: address, package_name: package_name, amount: amount, currency: currency) {
            result in
            
            switch result {
            case .success(let bonusRaw):
                self.billingService.getUserCurrency { result in
                    switch result {
                    case .success(let userCurrency):
                        completion(.success(TransactionBonus(value: bonusRaw.bonus, currency: Currency(userCurrencyRaw: userCurrency))))
                    case .failure: break
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getPaymentMethods(value: String, currency: String, completion: @escaping (Result<[PaymentMethod], BillingError>) -> Void) {
        billingService.getPaymentMethods(value: value, currency: currency) {
            result in
            
            switch result {
            case .success(let paymentMethodsRaw):
                if let rawMethods = paymentMethodsRaw.items {
                    var paymentMethods: [PaymentMethod] = []
                    for rawMethod in rawMethods {
                        paymentMethods.append(PaymentMethod(raw: rawMethod))
                    }
                    completion(.success(paymentMethods))
                } else {
                    completion(.failure(.failed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getDeveloperAddress(package: String, completion: @escaping (Result<String, AptoideServiceError>) -> Void) {
        aptoideService.getDeveloperWalletAddressByPackageName(package: package) {
            result in
            
            switch result {
            case .success(let addressRaw):
                completion(.success(addressRaw.data.address))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func createTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void) {
        billingService.createTransaction(wa: wa, raw: raw) { result in completion(result) }
    }
    
    internal func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<Transaction, TransactionError>) -> Void) {
        billingService.getTransactionInfo(uid: uid, wa: wa) {
            result in
            switch result {
            case .success(let transactionRaw):
                if ["PENDING", "PENDING_SERVICE_AUTHORIZATION", "PROCESSING", "PENDING_USER_PAYMENT", "SETTLED"].contains(transactionRaw.status) {
                    // Deal with incomplete transaction
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.getTransactionInfo(uid: uid, wa: wa) {
                            result in completion(result)
                        }
                    }
                } else if ["INVALID_TRANSACTION", "FAILED", "CANCELED", "FRAUD", "UNKNOWN"].contains(transactionRaw.status) {
                    
                    AnalyticsUseCases.shared.recordPaymentStatus(status: transactionRaw.status)
                    // Deal with different types of errors
                    completion(.failure(.failed()))
                } else if transactionRaw.status == "COMPLETED" {
                    
                    AnalyticsUseCases.shared.recordPaymentStatus(status: transactionRaw.status)
                    completion(.success(Transaction(raw: transactionRaw)))
                } else {
                    // Deal with incomplete transaction
                    DispatchQueue.main.async {
                        self.getTransactionInfo(uid: uid, wa: wa) {
                            result in completion(result)
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .timeOut:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.getTransactionInfo(uid: uid, wa: wa) {
                            result in completion(result)
                        }
                    }
                default:
                    completion(.failure(error))
                }
            }
        }
    }
    
    internal func getAllPurchases(domain: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        productService.getAllPurchases(domain: domain, wa: wa) {
            result in
            switch result {
            case .success(let purchasesRaw):
                var purchases: [Purchase] = []
                for raw in purchasesRaw.items {
                    purchases.append(Purchase(raw: raw))
                }
                completion(.success(purchases))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func getLatestPurchase(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void) {
        productService.getAllPurchasesBySKU(domain: domain, sku: sku, wa: wa) {
            result in
            switch result {
            case .success(let purchasesRaw):
                if let rawSKU = purchasesRaw.items.first {
                    let skuPurchase: Purchase = Purchase(raw: rawSKU)
                    completion(.success(skuPurchase))
                } else {
                    completion(.success(nil))
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func getPurchasesByState(domain: String, state: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        productService.getPurchasesByState(domain: domain, state: state, wa: wa) {
            result in
            switch result {
            case .success(let purchasesRaw):
                var purchases: [Purchase] = []
                for raw in purchasesRaw.items {
                    purchases.append(Purchase(raw: raw))
                }
                completion(.success(purchases))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    internal func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.acknowledgePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.consumePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func verifyPurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void) {
        productService.getPurchaseInformation(domain: domain, uid: uid, wa: wa) {
            result in
            switch result {
            case .success(let purchaseRaw):
                self.productService.getDeveloperPublicKey(domain: domain) {
                    result in
                    switch result {
                    case .success(let publicKeyString):
                        let verified = self.verifyPurchaseSignature(publicKeyString: publicKeyString, signature: purchaseRaw.verification.signature, message: purchaseRaw.verification.originalData)
                        if verified {
                            completion(.success(Purchase(raw: purchaseRaw)))
                        } else {
                            completion(.failure(.purchaseVerificationFailed))
                        }
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    private func verifyPurchaseSignature(publicKeyString: String, signature: String, message: String) -> Bool {
        
        do {
            // important to be in the right form, otherwise SwiftyRSA will not accept it
            let trimmedPublicKeyString = publicKeyString
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "\\r\\n", with: "\n")
                .replacingOccurrences(of: "\\/", with: "/")
            
            let publicKey = try PublicKey(pemEncoded: trimmedPublicKeyString)
            let signature = try Signature(base64Encoded: signature)
            let clear = try ClearMessage(string: message, using: .utf8)
            let isSuccessful = try clear.verify(with: publicKey, signature: signature, digestType: .sha1)
            return isSuccessful
        } catch {
            return false
        }
    }
    
    internal func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<AdyenTransactionSession, TransactionError>) -> Void) {
        billingService.createAdyenTransaction(wa: wa, raw: raw) { result in
            switch result {
            case .success(let transactionResponse):
                completion(.success(AdyenTransactionSession(raw: transactionResponse)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void) {
        billingService.createBAPayPalTransaction(wa: wa, raw: raw) { result in
            
            switch result {
            case .success(_):
                self.storeBillingAgreementLocally(wa: wa.getWalletAddress())
            default: break
            }
            completion(result) }
    }
    
    internal func createBillingAgreementToken(completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void) {
        let returnURL = BuildConfiguration.billingServiceURL + "/gateways/paypal/billing-agreement/token/return/success"
        let cancelURL = BuildConfiguration.billingServiceURL + "/gateways/paypal/billing-agreement/token/return/cancel"
        
        let raw = CreateBillingAgreementTokenRaw(urls: CreateBillingAgreementTokenURLsRaw(returnURL: returnURL, cancelURL: cancelURL))
        
        if let wallet = walletService.getActiveWallet() {
            billingService.createBillingAgreementToken(wa: wallet, raw: raw) { result in
                completion(result) }
        } else { completion(.failure(.failed())) }
    }
    
    internal func cancelBillingAgreementToken(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            billingService.cancelBillingAgreementToken(token: token, wa: wallet) { result in
                completion(result) }
        } else { completion(.failure(.failed())) }
    }
    
    internal func cancelBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            billingService.cancelBillingAgreement(wa: wallet) { result in
                self.removeBillingAgreementLocally(wa: wallet.getWalletAddress())
                completion(result)
            }
        } else { completion(.failure(.failed())) }
    }
    
    internal func createBillingAgreement(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            billingService.createBillingAgreement(token: token, wa: wallet) { result in
                switch result {
                case .success(_):
                    self.storeBillingAgreementLocally(wa: wallet.getWalletAddress())
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else { completion(.failure(.failed())) }
    }
    
    private func storeBillingAgreementLocally(wa: String) {
        userPreferencesService.writeWalletBA(wa: wa)
    }
    
    private func removeBillingAgreementLocally(wa: String) {
        userPreferencesService.removeWalletBA(wa: wa)
    }
    
    internal func getBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            billingService.getBillingAgreement(wa: wallet) { result in completion(result) }
        } else { completion(.failure(.failed())) }
    }
    
    internal func hasBillingAgreement() -> Bool {
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            return userPreferencesService.getWalletBA(wa: wa) != ""
        } else { return false }
    }
    
    internal func getLastPaymentMethod() -> Method? {
        return userPreferencesService.getLastPaymentMethod()
    }
    
    internal func setLastPaymentMethod(paymentMethod: Method) {
        userPreferencesService.setLastPaymentMethod(paymentMethod: paymentMethod)
    }
    
    internal func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void) {
        billingService.transferAPPC(wa: wa, raw: raw) { result in completion(result) }
    }
}
