//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

protocol TransactionRepositoryProtocol {
    
    func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, completion: @escaping (Result<TransactionBonus, TransactionError>) -> Void)
    
    func getPaymentMethods(value: String, currency: Coin, completion: @escaping (Result<[PaymentMethod], BillingError>) -> Void)
    
    func getDeveloperAddress(package: String, completion: @escaping (Result<String, AptoideServiceError>) -> Void)
    
    func createTransaction(wa: String, waSignature: String, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void)
    
    func getTransactionInfo(uid: String, wa: String, waSignature: String, completion: @escaping (Result<Transaction, TransactionError>) -> Void) 
    
    func getAllPurchases(domain: String, wa: String, waSignature: String, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void)
    
    func getLatestPurchase(domain: String, sku: String, wa: String, waSignature: String, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void)
    
    func getPurchasesByState(domain: String, state: String, wa: String, waSignature: String, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void)
    
    func acknowledgePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func consumePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func verifyPurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void)
    
    func createBAPayPalTransaction(wa: String, waSignature: String, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void)
    
    func createBillingAgreementToken(completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void)
    
    func cancelBillingAgreementToken(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func cancelBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func createBillingAgreement(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func getBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func hasBillingAgreement() -> Bool
    
    func getLastPaymentMethod() -> String
    
    func setLastPaymentMethod(paymentMethod: String)
    
}

