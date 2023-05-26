//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

class AppCoinProductServiceClient : AppCoinProductService {
    
    private let endpoint: String
    
    init(endpoint: String = "https://api.dev.catappult.io/productv2/8.20200701") {
        self.endpoint = endpoint
    }
    
    func getProductInformation(domain: String, result: @escaping (Result<GetProductInformationRaw, ProductServiceError>) -> Void) {
        if let url = URL(string: endpoint + "/applications/\(domain)/inapp/consumables") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(GetProductInformationRaw.self, from: data) {
                        result(.success(findResult))
                    } else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
    func getProductInformation(domain: String, sku: String, result: @escaping (Result<GetProductInformationRaw, ProductServiceError>) -> Void) {
        if let url = URL(string: endpoint + "/applications/\(domain)/inapp/consumables/?skus=\(sku)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(GetProductInformationRaw.self, from: data) {
                        result(.success(findResult))
                    } else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
    func acknowledgePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        let route = "/applications/\(domain)/inapp/purchases/\(uid)/acknowledge"
        if let url = URL(string: endpoint + route + "?wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed()))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode != 204 {
                            completion(.failure(.failed()))
                        } else {
                            completion(.success(true))
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func consumePurchase(domain: String, uid: String, wa: String, waSignature: String, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        let route = "/applications/\(domain)/inapp/purchases/\(uid)/consume"
        if let url = URL(string: endpoint + route + "?wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed()))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode != 204 {
                            completion(.failure(.failed()))
                        } else {
                            completion(.success(true))
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func getPurchaseInformation(domain: String, uid: String, wa: String, waSignature: String, result: @escaping (Result<PurchaseInformationRaw, ProductServiceError>) -> Void) {
        let route = "/applications/\(domain)/inapp/consumable/purchases/\(uid)"
        if let url = URL(string: endpoint + route + "?wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(PurchaseInformationRaw.self, from: data) {
                        result(.success(findResult))
                    } else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
    func getAllPurchases(domain: String, wa: String, waSignature: String, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void) {
        let route = "/applications/\(domain)/inapp/consumable/purchases"
        if let url = URL(string: endpoint + route + "?wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(GetPurchasesRaw.self, from: data) {
                        result(.success(findResult))
                    } else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
    func getAllPurchasesBySKU(domain: String, sku: String, wa: String, waSignature: String, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void) {
        let route = "/applications/\(domain)/inapp/consumable/purchases"
        if let url = URL(string: endpoint + route + "?sku=\(sku)&wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(GetPurchasesRaw.self, from: data) {
                        result(.success(findResult))
                    } else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
    func getPurchasesByState(domain: String, state: String, wa: String, waSignature: String, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void) {
        let route = "/applications/\(domain)/inapp/consumable/purchases"
        if let url = URL(string: endpoint + route + "?state=\(state)&wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(GetPurchasesRaw.self, from: data) {
                        result(.success(findResult))
                    } else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
    func getDeveloperPublicKey(domain: String, completion: @escaping (Result<String, ProductServiceError>) -> Void) {
        if let url = URL(string: endpoint + "/applications/\(domain)/public-key") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = String(data: data, encoding: .utf8) {
                        completion(.success(findResult))
                    } else {
                        completion(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
    
}
