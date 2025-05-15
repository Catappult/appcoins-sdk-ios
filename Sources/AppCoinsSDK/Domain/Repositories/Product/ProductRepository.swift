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

    internal func getProduct(domain: String, product: String, currency: Currency, discountPolicy: String? = nil, completion: @escaping (Result<Product, ProductServiceError>) -> Void) {
        productService.getProductInformation(domain: domain, sku: product, currency: currency, discountPolicy: discountPolicy) {
            result in
            
            switch result {
            case .success(let productRaw):
                if let productRaw = productRaw {
                    completion(.success(Product(raw: productRaw)))
                } else {
                    completion(.failure(.failed(message: "Product Not Found", description: "Product not found at ProductRepository.swift:getProduct", request: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getAllProducts(domain: String, currency: Currency, discountPolicy: String? = nil, completion: @escaping (Result<[Product], ProductServiceError>) -> Void) {
        productService.getProductInformation(domain: domain, currency: currency, discountPolicy: discountPolicy) {
            result in
            
            switch result {
            case .success(let productsRaw):
                var products : [Product] = []
                for productRaw in productsRaw {
                    products.append(Product(raw: productRaw))
                }
                completion(.success(products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getProductAppcValue(product: Product, productCurrency: Currency, completion: @escaping (Result<String, BillingError>) -> Void) {
        billingService.convertCurrency(money: product.priceValue, fromCurrency: productCurrency, toCurrency: Currency.APPC) {
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
