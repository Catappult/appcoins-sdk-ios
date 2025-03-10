//
//  ProductUseCases.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class ProductUseCases {
    
    static var shared: ProductUseCases = ProductUseCases()
    
    private var repository: ProductRepositoryProtocol
    private var currencyRepository: CurrencyRepositoryProtocol
    
    private init(repository: ProductRepositoryProtocol = ProductRepository(), currencyRepository: CurrencyRepositoryProtocol = CurrencyRepository()) {
        self.repository = repository
        self.currencyRepository = currencyRepository
    }
    
    internal func getProduct(domain: String, product: String, completion: @escaping (Result<Product, ProductServiceError>) -> Void) {
        currencyRepository.getUserCurrency { result in
            switch result {
            case .success(let userCurrency): 
                self.repository.getProduct(domain: domain, product: product, currency: userCurrency) { result in completion(result) }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    completion(.failure(.failed(message: message, description: description, request: request)))
                case .noInternet(let message, let description, let request):
                    completion(.failure(.noInternet(message: message, description: description,  request: request)))
                }
            }
        }
    }
    
    internal func getAllProducts(domain: String, completion: @escaping (Result<[Product], ProductServiceError>) -> Void) {
        currencyRepository.getUserCurrency { result in
            switch result {
            case .success(let userCurrency):
                self.repository.getAllProducts(domain: domain, currency: userCurrency) { result in completion(result) }
            case .failure(let error):
                switch error {
                case .failed(let message, let description, let request):
                    completion(.failure(.failed(message: message, description: description, request: request)))
                case .noInternet(let message, let description, let request):
                    completion(.failure(.noInternet(message: message, description: description,  request: request)))
                }
            }
        }
    }
}
