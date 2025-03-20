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
    
    internal func getProductInformation(domain: String, currency: Currency, result: @escaping (Result<[ProductRaw], ProductServiceError>) -> Void) {
        var products: [ProductRaw] = []
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumables"
            urlComponents.queryItems = [
                URLQueryItem(name: "currency", value: currency.currency),
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                func getNextProductsBatch(url: URL) {
                    var request = URLRequest(url: url)
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    request.httpMethod = "GET"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 10
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getProductInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getProductInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let findResult = try JSONDecoder().decode(GetProductInformationRaw.self, from: data)
                                    products.append(contentsOf: findResult.items)
                                    
                                    if let nextString = findResult.next?.url, let nextURL = URL(string: nextString) {
                                        getNextProductsBatch(url: nextURL)
                                    } else {
                                        result(.success(products))
                                    }
                                } else {
                                    result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinProductServiceClient.swift:getProductInformation")))
                                }
                            } catch {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinProductServiceClient.swift:getProductInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    }
                    task.resume()
                }
                getNextProductsBatch(url: url)
            }
        }
    }
    
    internal func getProductInformation(domain: String, sku: String, currency: Currency, result: @escaping (Result<ProductRaw?, ProductServiceError>) -> Void) {
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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getProductInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getProductInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetProductInformationRaw.self, from: data)
                                result(.success(findResult.items.first))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinProductServiceClient.swift:getProductInformation")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinProductServiceClient.swift:getProductInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                
                if let token = wa.getAuthToken() {
                    request.setValue(token, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:acknowledgePurchase", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:acknowledgePurchase", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        if let httpResponse = response as? HTTPURLResponse {
                            let statusCode = httpResponse.statusCode
                            if statusCode != 204 {
                                completion(.failure(.failed(message: "Service Failed", description: "The server hasn't successfully fulfilled the request from endpoint: \(url). Status code: \(statusCode) at AppCoinProductServiceClient.swift:acknowledgePurchase")))
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
                
                if let token = wa.getAuthToken() {
                    request.setValue(token, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:consumePurchase", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:consumePurchase", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        if let httpResponse = response as? HTTPURLResponse {
                            let statusCode = httpResponse.statusCode
                            if statusCode != 204 {
                                completion(.failure(.failed(message: "Service Failed", description: "The server hasn't successfully fulfilled the request from endpoint: \(url). Status code: \(statusCode) at AppCoinProductServiceClient.swift:consumePurchase")))
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
    
    internal func getPurchaseInformation(domain: String, uid: String, wa: Wallet, result: @escaping (Result<PurchaseRaw, ProductServiceError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases/\(uid)"
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                if let token = wa.getAuthToken() {
                    request.setValue(token, forHTTPHeaderField: "Authorization")
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getPurchaseInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getPurchaseInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(PurchaseRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinProductServiceClient.swift:getPurchaseInformation")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinProductServiceClient.swift:getPurchaseInformation", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    internal func getAllPurchases(domain: String, wa: Wallet, result: @escaping (Result<[PurchaseRaw], ProductServiceError>) -> Void) {
        var purchases: [PurchaseRaw] = []
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases"
            urlComponents.queryItems = [
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                func getNextPurchasesBatch(url: URL) {
                    var request = URLRequest(url: url)
                    
                    if let ewt = wa.getAuthToken() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    request.httpMethod = "GET"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 10
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getAllPurchases", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getAllPurchases", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let findResult = try JSONDecoder().decode(GetPurchasesRaw.self, from: data)
                                    purchases.append(contentsOf: findResult.items)
                                    
                                    if let nextString = findResult.next?.url, let nextURL = URL(string: nextString) {
                                        getNextPurchasesBatch(url: nextURL)
                                    } else {
                                        result(.success(purchases))
                                    }
                                } else {
                                    result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinProductServiceClient.swift:getAllPurchases")))
                                }
                            } catch {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinProductServiceClient.swift:getAllPurchases", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    }
                    task.resume()
                }
                getNextPurchasesBatch(url: url)
            }
        }
    }
    
    internal func getAllPurchasesBySKU(domain: String, sku: String, wa: Wallet, result: @escaping (Result<[PurchaseRaw], ProductServiceError>) -> Void) {
        var purchases: [PurchaseRaw] = []
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases"
            urlComponents.queryItems = [
                URLQueryItem(name: "sku", value: sku),
                URLQueryItem(name: "platform", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                func getNextPurchasesBatch(url: URL) {
                    var request = URLRequest(url: url)
                    
                    if let ewt = wa.getAuthToken() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    request.httpMethod = "GET"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 10
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getAllPurchasesBySKU", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getAllPurchasesBySKU", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let findResult = try JSONDecoder().decode(GetPurchasesRaw.self, from: data)
                                    purchases.append(contentsOf: findResult.items)
                                    
                                    if let nextString = findResult.next?.url, let nextURL = URL(string: nextString) {
                                        getNextPurchasesBatch(url: nextURL)
                                    } else {
                                        result(.success(purchases))
                                    }
                                } else {
                                    result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinProductServiceClient.swift:getAllPurchasesBySKU")))
                                }
                            } catch {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinProductServiceClient.swift:getAllPurchasesBySKU", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    }
                    task.resume()
                }
                getNextPurchasesBatch(url: url)
            }
        }
    }
    
    internal func getPurchasesByState(domain: String, state: [String], wa: Wallet, result: @escaping (Result<[PurchaseRaw], ProductServiceError>) -> Void) {
        var purchases: [PurchaseRaw] = []
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/applications/\(domain)/inapp/consumable/purchases"
            
            let stateString = state.joined(separator: ",")
            let stateQueryItem = URLQueryItem(name: "state", value: stateString)
            
            urlComponents.queryItems = [stateQueryItem, URLQueryItem(name: "platform", value: "IOS")]
            
            if let url = urlComponents.url {
                func getNextPurchasesBatch(url: URL) {
                    var request = URLRequest(url: url)
                    
                    if let ewt = wa.getAuthToken() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    request.httpMethod = "GET"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 10
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getPurchasesByState", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getPurchasesByState", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let findResult = try JSONDecoder().decode(GetPurchasesRaw.self, from: data)
                                    purchases.append(contentsOf: findResult.items)
                                    
                                    if let nextString = findResult.next?.url, let nextURL = URL(string: nextString) {
                                        getNextPurchasesBatch(url: nextURL)
                                    } else {
                                        result(.success(purchases))
                                    }
                                } else {
                                    result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinProductServiceClient.swift:getPurchasesByState")))
                                }
                            } catch {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinProductServiceClient.swift:getPurchasesByState", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    }
                    task.resume()
                }
                getNextPurchasesBatch(url: url)
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
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinProductServiceClient.swift:getDeveloperPublicKey", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinProductServiceClient.swift:getDeveloperPublicKey", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        if let data = data, let findResult = String(data: data, encoding: .utf8) {
                            completion(.success(findResult))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Unable to retrieve the developer’s public key at AppCoinProductServiceClient.swift:getDeveloperPublicKey", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
}
