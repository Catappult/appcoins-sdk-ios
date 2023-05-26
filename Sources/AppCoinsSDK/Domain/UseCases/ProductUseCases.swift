//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

class ProductUseCases {
    
    private var repository: ProductRepositoryProtocol
    
    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
    }
    
    func getProduct(domain: String, product: String, completion: @escaping (Result<Product, ProductServiceError>) -> Void) {
        repository.getProduct(domain: domain, product: product) { result in completion(result) }
    }
    
    func getAllProducts(domain: String, completion: @escaping (Result<[Product], ProductServiceError>) -> Void) {
        repository.getAllProducts(domain: domain) { result in completion(result) }
    }
    
    func getProductAppcValue(product: Product, completion: @escaping (Result<String, BillingError>) -> Void) {
        repository.getProductAppcValue(product: product) { result in completion(result) }
    }
    
}
