//
//  ProductRepositoryProtocol.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol ProductRepositoryProtocol {
    
    func getProduct(domain: String, product: String, completion: @escaping (Result<Product, ProductServiceError>) -> Void)
    func getAllProducts(domain: String, completion: @escaping (Result<[Product], ProductServiceError>) -> Void)
    func getProductAppcValue(product: Product, completion: @escaping (Result<String, BillingError>) -> Void)
    
}

