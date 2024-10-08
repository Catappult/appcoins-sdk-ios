//
//  AppCoinProductServiceClient.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class AppCoinProductServiceClient : AppCoinProductService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.productServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func getProductInformation(domain: String, currency: Currency, result: @escaping (Result<GetProductInformationRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumables"
            urlComponents.queryItems = [
                URLQueryItem(name: "currency", value: currency.currency),
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    }
    
    internal func getProductInformation(domain: String, sku: String, currency: Currency, result: @escaping (Result<GetProductInformationRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumables"
            urlComponents.queryItems = [
                URLQueryItem(name: "skus", value: sku),
                URLQueryItem(name: "currency", value: currency.currency),
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    }
    
    internal func acknowledgePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/purchases/\(uid)/acknowledge"
            
            if let url = urlComponents.url {
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
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
    }
    
    internal func consumePurchase(domain: String, uid: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/purchases/\(uid)/consume"
            
            if let url = urlComponents.url {
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
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
    }
    
    internal func getPurchaseInformation(domain: String, uid: String, wa: Wallet, result: @escaping (Result<PurchaseInformationRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases/\(uid)"
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    }
    
    internal func getAllPurchases(domain: String, wa: Wallet, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases"
            urlComponents.queryItems = [
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    }
    
    internal func getAllPurchasesBySKU(domain: String, sku: String, wa: Wallet, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases"
            urlComponents.queryItems = [
                URLQueryItem(name: "sku", value: sku),
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    }
    
    internal func getPurchasesByState(domain: String, state: String, wa: Wallet, result: @escaping (Result<GetPurchasesRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases"
            urlComponents.queryItems = [
                URLQueryItem(name: "state", value: state),
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    }
    
    internal func getDeveloperPublicKey(domain: String, completion: @escaping (Result<String, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/public-key"
            urlComponents.queryItems = [
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    
}
