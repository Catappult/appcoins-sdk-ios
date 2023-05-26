//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation


protocol AppCoinBillingService {
    
    func createTransaction(wa: String, waSignature: String, raw: CreateTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void)
    func getPaymentMethods(value: String, currency: Coin, result: @escaping (Result<GetPaymentMethodsRaw, BillingError>) -> Void)
    func convertCurrency(money: String, fromCurrency: Coin, toCurrency: Coin, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void)
    func getTransactionInfo(uid: String, wa: String, waSignature: String, completion: @escaping (Result<GetTransactionInfoRaw, TransactionError>) -> Void)
    
}

enum Coin: String {
    
    case ETH = "ETH"
    case APPC = "APPC"
    case EUR = "EUR"
    case USD = "USD"
    
}

extension Coin {
    
    var symbol: String {
        let locale = NSLocale(localeIdentifier: self.rawValue)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: self.rawValue) ?? ""
    }
    
}
