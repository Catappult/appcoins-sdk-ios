//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

class TransactionUseCases {
    
    private var repository: TransactionRepositoryProtocol
    
    init(repository: TransactionRepositoryProtocol = TransactionRepository()) {
        self.repository = repository
    }
    
    func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, completion: @escaping (Result<TransactionBonus, TransactionError>) -> Void) {
        repository.getTransactionBonus(address: address, package_name: package_name, amount: amount, currency: currency) { result in completion(result) }
    }
    
    func getPaymentMethods(value: String, currency: Coin, completion: @escaping (Result<[PaymentMethod], BillingError>) -> Void) {
        repository.getPaymentMethods(value: value, currency: currency) { result in completion(result) }
    }
    
    func getDeveloperAddress(package: String, completion: @escaping (Result<String, AptoideServiceError>) -> Void) {
        repository.getDeveloperAddress(package: package) {result in completion(result)}
    }
    
    func createTransaction(wa: String, waSignature: String, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void) {
        repository.createTransaction(wa: wa, waSignature: waSignature, raw: raw) {result in completion(result)}
    }
    
    func getTransactionInfo(uid: String, wa: String, waSignature: String, completion: @escaping (Result<Transaction, TransactionError>) -> Void) {
        repository.getTransactionInfo(uid: uid, wa: wa, waSignature: waSignature) {result in completion(result)}
    }
    
    func getAllPurchases(domain: String, wa: String, waSignature: String, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        repository.getAllPurchases(domain: domain, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func getLatestPurchase(domain: String, sku: String, wa: String, waSignature: String, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void) {
        repository.getLatestPurchase(domain: domain, sku: sku, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func getPurchasesByState(domain: String, state: String, wa: String, waSignature: String, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void) {
        repository.getPurchasesByState(domain: domain, state: state, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func acknowledgePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.acknowledgePurchase(domain: domain, uid: uid, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func consumePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.consumePurchase(domain: domain, uid: uid, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func verifyPurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void) {
        repository.verifyPurchase(domain: domain, uid: uid, wa: wa, waSignature: waSignature) { result in completion(result) }
    }
    
    func createBAPayPalTransaction(wa: String, waSignature: String, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void) {
        repository.createBAPayPalTransaction(wa: wa, waSignature: waSignature, raw: raw) { result in completion(result) }
    }
    
    func createBillingAgreementToken(completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void) {
        repository.createBillingAgreementToken() { result in completion(result) }
    }
    
    func cancelBillingAgreementToken(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.cancelBillingAgreementToken(token: token) { result in completion(result) }
    }
    
    func cancelBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.cancelBillingAgreement() { result in completion(result) }
    }
    
    func createBillingAgreement(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.createBillingAgreement(token: token) { result in completion(result) }
    }
    
    func getBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        repository.getBillingAgreement() { result in completion(result) }
    }
    
    func hasBillingAgreement() -> Bool {
        return repository.hasBillingAgreement()
    }
    
    func getLastPaymentMethod() -> String {
        return repository.getLastPaymentMethod()
    }
    
    func setLastPaymentMethod(paymentMethod: String) {
        repository.setLastPaymentMethod(paymentMethod: paymentMethod)
    }
    
}