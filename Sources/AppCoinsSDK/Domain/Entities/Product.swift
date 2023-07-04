//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
import SwiftyRSA

public struct Product {
    
    public let sku: String
    public let title: String
    public let description: String?
    public let priceCurrency: String
    public let priceValue: String
    public let priceLabel: String
    public let priceSymbol: String
    
    init(sku: String, title: String, description: String, priceCurrency: String, priceValue: String, priceLabel: String, priceSymbol: String) {
        self.sku = sku
        self.title = title
        self.description = description
        self.priceCurrency = priceCurrency
        self.priceValue = priceValue
        self.priceLabel = priceLabel
        self.priceSymbol = priceSymbol
    }
    
    init(raw: ProductInformationRaw) {
        self.sku = raw.sku
        self.title = raw.title
        self.description = raw.description
        self.priceCurrency = raw.price.currency
        self.priceValue = raw.price.value
        self.priceLabel = raw.price.label
        self.priceSymbol = raw.price.symbol
    }
    
    static public func products(domain: String = (Bundle.main.bundleIdentifier ?? ""), for identifiers: [String]? = nil, completion: @escaping (Result<[Product], AppCoinsSDKError>) -> Void) {

        let productUseCases: ProductUseCases = ProductUseCases()
        
        if let identifiers = identifiers {
            productUseCases.getAllProducts(domain: domain) { result in
                switch result {
                case .success(let products):
                    var finalProducts : [Product] = []
                    for product in products {
                        if identifiers.contains(product.sku) {
                            finalProducts.append(product)
                        }
                    }
                    completion(.success(finalProducts))
                case .failure(let failure):
                    switch failure {
                    case .failed:
                        completion(.failure(.systemError))
                    case .noInternet:
                        completion(.failure(.networkError))
                    default:
                        completion(.failure(.systemError))
                    }
                }
            }
        } else {
            productUseCases.getAllProducts(domain: domain) { result in
                switch result {
                case .success(let products):
                    completion(.success(products))
                case .failure(let failure):
                    switch failure {
                    case .failed:
                        completion(.failure(.systemError))
                    case .noInternet:
                        completion(.failure(.networkError))
                    default:
                        completion(.failure(.systemError))
                    }
                }
            }
        }
    }
    
    public func purchase(domain: String = (Bundle.main.bundleIdentifier ?? ""), payload: String = "", orderID: String = String(Date.timeIntervalSinceReferenceDate), completion: @escaping (TransactionResult) -> Void) {
        
        DispatchQueue.main.async {
            SDKViewController.presentPurchase()
            
            // product – the SKU product
            // domain – the app's domain registered in catappult
            // payload – information that the developer might want to pass with the transaction
            // orderID – a reference so that the developer can identify unique transactions
            NotificationCenter.default.post(name: NSNotification.Name("APPCBuildPurchase"), object: nil, userInfo: ["product" : self, "domain" : domain, "metadata" : payload, "reference" : orderID])
        }
        
        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("APPCPurchaseResult"), object: nil, queue: nil) { notification in
            if let userInfo = notification.userInfo {
                if let status = userInfo["TransactionResult"] as? TransactionResult {
                    completion(status)
                    
                    if let observer = observer {
                        NotificationCenter.default.removeObserver(observer)
                    }
                }
            }
        }
        
    }
    
}
