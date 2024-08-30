//
//  ProductRepositoryProtocol.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol ProductRepositoryProtocol {
    
    func getProduct(domain: String, product: String, currency: Currency, completion: @escaping (Result<Product, ProductServiceError>) -> Void)
    func getAllProducts(domain: String, currency: Currency, completion: @escaping (Result<[Product], ProductServiceError>) -> Void)
    func getProductAppcValue(product: Product, productCurrency: Currency, completion: @escaping (Result<String, BillingError>) -> Void)
    
}

