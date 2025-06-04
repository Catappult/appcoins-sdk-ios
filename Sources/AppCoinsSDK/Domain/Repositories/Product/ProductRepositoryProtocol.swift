//
//  ProductRepositoryProtocol.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal protocol ProductRepositoryProtocol {
    func getProduct(domain: String, product: String, currency: Currency, discountPolicy: DiscountPolicy?, completion: @escaping (Result<Product, ProductServiceError>) -> Void)
    func getAllProducts(domain: String, currency: Currency, discountPolicy: DiscountPolicy?, completion: @escaping (Result<[Product], ProductServiceError>) -> Void)
}
