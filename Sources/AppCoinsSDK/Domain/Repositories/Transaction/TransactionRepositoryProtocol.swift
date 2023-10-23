//
//  TransactionRepositoryProtocol.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol TransactionRepositoryProtocol {
    
    func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, completion: @escaping (Result<TransactionBonus, TransactionError>) -> Void)
    
    func getPaymentMethods(value: String, currency: Coin, completion: @escaping (Result<[PaymentMethod], BillingError>) -> Void)
    
    func getDeveloperAddress(package: String, completion: @escaping (Result<String, AptoideServiceError>) -> Void)
    
    func createTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void)
    
    func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<Transaction, TransactionError>) -> Void)
    
    func getAllPurchases(domain: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void)
    
    func getLatestPurchase(domain: String, sku: String, wa: Wallet, completion: @escaping (Result<Purchase?, ProductServiceError>) -> Void)
    
    func getPurchasesByState(domain: String, state: String, wa: Wallet, completion: @escaping (Result<[Purchase], ProductServiceError>) -> Void)
    
    func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func verifyPurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Purchase, ProductServiceError>) -> Void)
    
    func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<AdyenTransactionSession, TransactionError>) -> Void)
    
    func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void)
    
    func createBillingAgreementToken(completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void)
    
    func cancelBillingAgreementToken(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func cancelBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func createBillingAgreement(token: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func getBillingAgreement(completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func hasBillingAgreement() -> Bool
    
    func getLastPaymentMethod() -> Method?
    
    func setLastPaymentMethod(paymentMethod: Method)
    
    func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void)
    
}


