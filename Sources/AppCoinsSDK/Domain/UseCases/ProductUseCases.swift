//
//  ProductUseCases.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class ProductUseCases {
    
    static var shared : ProductUseCases = ProductUseCases()
    
    private var repository: ProductRepositoryProtocol
    
    private init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
    }
    
    internal func getProduct(domain: String, product: String, completion: @escaping (Result<Product, ProductServiceError>) -> Void) {
        repository.getProduct(domain: domain, product: product) { result in completion(result) }
    }
    
    internal func getAllProducts(domain: String, completion: @escaping (Result<[Product], ProductServiceError>) -> Void) {
        repository.getAllProducts(domain: domain) { result in completion(result) }
    }
    
    internal func getProductAppcValue(product: Product, completion: @escaping (Result<String, BillingError>) -> Void) {
        repository.getProductAppcValue(product: product) { result in completion(result) }
    }
    
}
