//
//  ProductRepository.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class ProductRepository: ProductRepositoryProtocol {
    
    private let productService: AppCoinProductService = AppCoinProductServiceClient()
    private let billingService: AppCoinBillingService = AppCoinBillingClient()

    internal func getProduct(domain: String, product: String, currency: Coin = .EUR, completion: @escaping (Result<Product, ProductServiceError>) -> Void) {
        productService.getProductInformation(domain: domain, sku: product, currency: currency) {
            result in
            
            switch result {
            case .success(let productItemsRaw):
                if let productRaw = productItemsRaw.items?.first {
                    completion(.success(Product(raw: productRaw)))
                } else {
                    completion(.failure(.failed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getAllProducts(domain: String, currency: Coin = .EUR, completion: @escaping (Result<[Product], ProductServiceError>) -> Void) {
        productService.getProductInformation(domain: domain, currency: currency) {
            result in
            
            switch result {
            case .success(let productItemsRaw):
                if let productsRaw = productItemsRaw.items {
                    var products : [Product] = []
                    for productRaw in productsRaw {
                        products.append(Product(raw: productRaw))
                    }
                    completion(.success(products))
                } else {
                    completion(.failure(.failed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getProductAppcValue(product: Product, completion: @escaping (Result<String, BillingError>) -> Void) {
        
        if let fromCurrency = Coin(rawValue: product.priceCurrency) {
            billingService.convertCurrency(money: product.priceValue, fromCurrency: fromCurrency, toCurrency: .APPC) {
                result in
                switch result {
                case .success(let converted):
                    completion(.success(converted.value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
}
