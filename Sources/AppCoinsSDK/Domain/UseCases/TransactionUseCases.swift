//
//  TransactionUseCases.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class TransactionUseCases {
    
    static var shared : TransactionUseCases = TransactionUseCases()
    
    private var repository: TransactionRepositoryProtocol
    
    private init(repository: TransactionRepositoryProtocol = TransactionRepository()) {
        self.repository = repository
    }
    
    internal func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, completion: @escaping (Result<TransactionBonus, TransactionError>) -> Void) {
        repository.getTransactionBonus(address: address, package_name: package_name, amount: amount, currency: currency) { result in completion(result) }
    }
    
    internal func getPaymentMethods(value: String, currency: Coin, completion: @escaping (Result<[PaymentMethod], BillingError>) -> Void) {
        repository.getPaymentMethods(value: value, currency: currency) { result in completion(result) }
    }
    
    internal func getDeveloperAddress(package: String, completion: @escaping (Result<String, AptoideServiceError>) -> Void) {
        repository.getDeveloperAddress(package: package) {result in completion(result)}
    }
    
    internal func createTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void) {
        repository.createTransaction(wa: wa, raw: raw) {result in completion(result)}
    }
    
    internal func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<Transaction, TransactionError>) -> Void) {
        repository.getTransactionInfo(uid: uid, wa: wa) {result in completion(result)}
    }
    
    internal func getAllPurchases(domain: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        repository.getAllPurchases(domain: domain, wa: wa) { result in completion(result) }
    }
    
    internal func getLatestPurchase(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void) {
        repository.getLatestPurchase(domain: domain, sku: sku, wa: wa) { result in completion(result) }
    }
    
    internal func getPurchasesByState(domain: String, state: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        repository.getPurchasesByState(domain: domain, state: state, wa: wa) { result in completion(result) }
    }
    
    internal func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.acknowledgePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.consumePurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func verifyPurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void) {
        repository.verifyPurchase(domain: domain, uid: uid, wa: wa) { result in completion(result) }
    }
    
    internal func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<AdyenTransactionSession, TransactionError>) -> Void) {
        repository.createAdyenTransaction(wa: wa, raw: raw) { result in completion(result) }
    }
    
    internal func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void) {
        repository.createBAPayPalTransaction(wa: wa, raw: raw) { result in completion(result) }
    }
    
    internal func createBillingAgreementToken(completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void) {
        repository.createBillingAgreementToken() { result in completion(result) }
    }
    
    internal func cancelBillingAgreementToken(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.cancelBillingAgreementToken(token: token) { result in completion(result) }
    }
    
    internal func cancelBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.cancelBillingAgreement() { result in completion(result) }
    }
    
    internal func createBillingAgreement(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.createBillingAgreement(token: token) { result in completion(result) }
    }
    
    internal func getBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.getBillingAgreement() { result in completion(result) }
    }
    
    internal func hasBillingAgreement() -> Bool {
        return repository.hasBillingAgreement()
    }
    
    internal func getLastPaymentMethod() -> Method? {
        return repository.getLastPaymentMethod()
    }
    
    internal func setLastPaymentMethod(paymentMethod: Method) {
        repository.setLastPaymentMethod(paymentMethod: paymentMethod)
    }
    
    internal func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void) {
        repository.transferAPPC(wa: wa, raw: raw) { result in completion(result) }
    }
}
