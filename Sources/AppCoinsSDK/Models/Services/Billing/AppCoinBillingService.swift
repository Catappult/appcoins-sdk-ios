//
//  AppCoinBillingService.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol AppCoinBillingService {
    
    func getPaymentMethods(value: String, currency: Coin, wallet: Wallet, domain: String, result: @escaping (Result<GetPaymentMethodsRaw, BillingError>) -> Void)
    
    func convertCurrency(money: String, fromCurrency: Coin, toCurrency: Coin, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void)
    
    func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void)
    
    func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<GetTransactionInfoRaw, TransactionError>) -> Void)
    
    func createAPPCTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateAPPCTransactionResponseRaw, TransactionError>) -> Void)
    
    func createSandboxTransaction(wa: Wallet, raw: CreateSandboxTransactionRaw, completion: @escaping (Result<CreateSandboxTransactionResponseRaw, TransactionError>) -> Void)
    
    func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<CreateAdyenTransactionResponseRaw, TransactionError>) -> Void)
    
    func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void)
    
    func createBillingAgreementToken(wa: Wallet, raw: CreateBillingAgreementTokenRaw, completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void)
    
    func cancelBillingAgreementToken(token: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func cancelBillingAgreement(wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func createBillingAgreement(token: String, wa: Wallet, completion: @escaping (Result<CreateBillingAgreementResponseRaw, TransactionError>) -> Void)
    
    func getBillingAgreement(wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
}
