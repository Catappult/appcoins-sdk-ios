//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

protocol AppCoinProductService {
    
    func getProductInformation(domain: String, result: @escaping (Result<GetProductInformationRaw, ProductServiceError>) -> Void)
    func getProductInformation(domain: String, sku: String, result: @escaping (Result<GetProductInformationRaw, ProductServiceError>) -> Void)
    func acknowledgePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    func consumePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void)
    func getPurchaseInformation(domain: String, uid: String, wa: String, waSignature: String, result: @escaping (Result<PurchaseInformationRaw, ProductServiceError>) -> Void)
    func getAllPurchases(domain: String, wa: String, waSignature: String, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void)
    func getAllPurchasesBySKU(domain: String, sku: String, wa: String, waSignature: String, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void)
    func getPurchasesByState(domain: String, state: String, wa: String, waSignature: String, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void)
    func getDeveloperPublicKey(domain: String, completion: @escaping (Result<String, ProductServiceError>) -> Void)
}
