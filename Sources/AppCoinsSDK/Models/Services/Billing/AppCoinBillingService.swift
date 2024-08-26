//
//  AppCoinBillingService.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol AppCoinBillingService {
    
    func createTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void)
    
    func getPaymentMethods(value: String, currency: String, result: @escaping (Result<GetPaymentMethodsRaw, BillingError>) -> Void)
    
    func convertCurrency(money: String, fromCurrency: String, toCurrency: String?, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void)
    
    func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void)
    
    func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<GetTransactionInfoRaw, TransactionError>) -> Void)
    
    func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<CreateAdyenTransactionResponseRaw, TransactionError>) -> Void)
    
    func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void)
    
    func createBillingAgreementToken(wa: Wallet, raw: CreateBillingAgreementTokenRaw, completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void)
    
    func cancelBillingAgreementToken(token: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func cancelBillingAgreement(wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func createBillingAgreement(token: String, wa: Wallet, completion: @escaping (Result<CreateBillingAgreementResponseRaw, TransactionError>) -> Void)
    
    func getBillingAgreement(wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func getSupportedCurrencies(result: @escaping (Result<[CurrencyRaw], BillingError>) -> Void)
}
