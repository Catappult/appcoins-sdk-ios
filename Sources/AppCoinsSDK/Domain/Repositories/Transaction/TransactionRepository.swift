//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
import SwiftyRSA

class TransactionRepository: TransactionRepositoryProtocol {
    
    private let gamificationService: AppCoinGamificationService = AppCoinGamificationServiceClient()
    private let billingService: AppCoinBillingService = AppCoinBillingClient()
    private let aptoideService: AptoideService = AptoideServiceClient()
    private let productService: AppCoinProductService = AppCoinProductServiceClient()
    private let walletService: WalletLocalService = WalletLocalClient()
    private let userPreferencesService: UserPreferencesLocalService = UserPreferencesLocalClient()
    
    func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, completion: @escaping (Result<TransactionBonus, TransactionError>) -> Void) {
        gamificationService.getTransactionBonus(address: address, package_name: package_name, amount: amount, currency: currency) {
            result in
            
            switch result {
            case .success(let bonusRaw):
                if let currency = Coin(rawValue: bonusRaw.currency) {
                    completion(.success(TransactionBonus(value: bonusRaw.bonus, currency: currency)))
                } else {
                    completion(.failure(.failed()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPaymentMethods(value: String, currency: Coin, completion: @escaping (Result<[PaymentMethod], BillingError>) -> Void) {
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
    
    func getDeveloperAddress(package: String, completion: @escaping (Result<String, AptoideServiceError>) -> Void) {
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
    
    func createTransaction(wa: String, waSignature: String, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void) {
        billingService.createTransaction(wa: wa, waSignature: waSignature, raw: raw) {
            result in
            
            switch result {
                case .success(_): self.setLastPaymentMethod(paymentMethod: "appcoins_credits")
                default: break
            }
            completion(result)}
    }
    
    func getTransactionInfo(uid: String, wa: String, waSignature: String, completion: @escaping (Result<Transaction, TransactionError>) -> Void) {
        billingService.getTransactionInfo(uid: uid, wa: wa, waSignature: waSignature) {
            result in
            switch result {
            case .success(let transactionRaw):
                if ["PENDING", "PENDING_SERVICE_AUTHORIZATION", "PROCESSING", "PENDING_USER_PAYMENT", "SETTLED"].contains(transactionRaw.status) {
                    // Deal with incomplete transaction
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.getTransactionInfo(uid: uid, wa: wa, waSignature: waSignature) {
                            result in completion(result)
                        }
                    }
                } else if ["INVALID_TRANSACTION", "FAILED", "CANCELED", "FRAUD", "UNKNOWN"].contains(transactionRaw.status) {
                    // Deal with different types of errors
                    completion(.failure(.failed()))
                } else if transactionRaw.status == "COMPLETED" {
                    completion(.success(Transaction(raw: transactionRaw)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAllPurchases(domain: String, wa: String, waSignature: String, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        productService.getAllPurchases(domain: domain, wa: wa, waSignature: waSignature) {
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
    
    func getLatestPurchase(domain: String, sku: String, wa: String, waSignature: String, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void) {
        productService.getAllPurchasesBySKU(domain: domain, sku: sku, wa: wa, waSignature: waSignature) {
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
    
    func getPurchasesByState(domain: String, state: String, wa: String, waSignature: String, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        productService.getPurchasesByState(domain: domain, state: state, wa: wa, waSignature: waSignature) {
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
    
    func acknowledgePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.acknowledgePurchase(domain: domain, uid: uid, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func consumePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        productService.consumePurchase(domain: domain, uid: uid, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func verifyPurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void) {
        productService.getPurchaseInformation(domain: domain, uid: uid, wa: wa, waSignature: waSignature) {
            result in
            
            switch result {
            case .success(let purchaseRaw):
                self.productService.getDeveloperPublicKey(domain: domain) {
                    result in
                    
                    switch result {
                    case .success(let publicKeyString):
                        let verified = self.verifyPurchaseSignature(publicKeyString: publicKeyString, signature: purchaseRaw.verification.signature, message: purchaseRaw.verification.data)
                        
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
    
    func createBAPayPalTransaction(wa: String, waSignature: String, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void) {
        billingService.createBAPayPalTransaction(wa: wa, waSignature: waSignature, raw: raw) { result in
            
            switch result {
                case .success(_):
                    self.setLastPaymentMethod(paymentMethod: "paypal")
                    self.storeBillingAgreementLocally(wa: wa)
                default: break
            }
            completion(result) }
    }
    
    func createBillingAgreementToken(completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void) {
        let returnURL = BuildConfiguration.billingServiceURL + "/gateways/paypal/billing-agreement/token/return/success"
        let cancelURL = BuildConfiguration.billingServiceURL + "/gateways/paypal/billing-agreement/token/return/cancel"

        let raw = CreateBillingAgreementTokenRaw(urls: CreateBillingAgreementTokenURLsRaw(returnURL: returnURL, cancelURL: cancelURL))
        
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            let waSignature = wallet.getSignedWalletAddress()
            
            billingService.createBillingAgreementToken(wa: wa, waSignature: waSignature, raw: raw) { result in
                completion(result) }
        } else { completion(.failure(.failed())) }
    }
    
    func cancelBillingAgreementToken(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            let waSignature = wallet.getSignedWalletAddress()
            
            billingService.cancelBillingAgreementToken(token: token, wa: wa, waSignature: waSignature) { result in
                completion(result) }
        } else { completion(.failure(.failed())) }
    }
    
    func cancelBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            let waSignature = wallet.getSignedWalletAddress()
            
            billingService.cancelBillingAgreement(wa: wa, waSignature: waSignature) { result in
                self.removeBillingAgreementLocally(wa: wa)
                completion(result)
            }
        } else { completion(.failure(.failed())) }
    }
    
    func createBillingAgreement(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            let waSignature = wallet.getSignedWalletAddress()
            
            billingService.createBillingAgreement(token: token, wa: wa, waSignature: waSignature) { result in
                switch result {
                case .success(_):
                    self.storeBillingAgreementLocally(wa: wa)
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
    
    func getBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            let waSignature = wallet.getSignedWalletAddress()
            
            billingService.getBillingAgreement(wa: wa, waSignature: waSignature) { result in completion(result) }
        } else { completion(.failure(.failed())) }
    }
    
    func hasBillingAgreement() -> Bool {
        if let wallet = walletService.getActiveWallet() {
            let wa = wallet.getWalletAddress()
            return userPreferencesService.getWalletBA(wa: wa) != ""
        } else { return false }
    }
    
    func getLastPaymentMethod() -> String {
        return userPreferencesService.getLastPaymentMethod()
    }
    
    func setLastPaymentMethod(paymentMethod: String) {
        userPreferencesService.setLastPaymentMethod(paymentMethod: paymentMethod)
    }
    
}