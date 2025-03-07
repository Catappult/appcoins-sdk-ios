//
//  AppCoinProductService.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol AppCoinProductService {
    
    func getProductInformation(domain: String, currency: Currency, result: @escaping (Result<[ProductRaw], ProductServiceError>) -> Void)
    
    func getProductInformation(domain: String, sku: String, currency: Currency, result: @escaping (Result<ProductRaw?, ProductServiceError>) -> Void)
    
    func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    
    func getPurchaseInformation(domain: String, uid: String, wa: Wallet, result: @escaping (Result<PurchaseRaw, ProductServiceError>) -> Void)
    
    func getAllPurchases(domain: String, wa: Wallet, result: @escaping (Result<[PurchaseRaw], ProductServiceError>) -> Void)
    
    func getAllPurchasesBySKU(domain: String, sku: String, wa: Wallet, result: @escaping (Result<[PurchaseRaw], ProductServiceError>) -> Void)
    
    func getPurchasesByState(domain: String, state: [String], wa: Wallet, result: @escaping (Result<[PurchaseRaw], ProductServiceError>) -> Void)
    
    func getDeveloperPublicKey(domain: String, completion: @escaping (Result<String, ProductServiceError>) -> Void)
}
