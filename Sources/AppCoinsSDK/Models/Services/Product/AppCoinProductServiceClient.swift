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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetProductInformationRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url)")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetProductInformationRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url)")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        if let httpResponse = response as? HTTPURLResponse {
                            let statusCode = httpResponse.statusCode
                            if statusCode != 204 {
                                completion(.failure(.failed(message: "Service Failed", description: "The server hasn't successfully fulfilled the request from endpoint: \(url). Status code: \(statusCode)")))
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
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        if let httpResponse = response as? HTTPURLResponse {
                            let statusCode = httpResponse.statusCode
                            if statusCode != 204 {
                                completion(.failure(.failed(message: "Service Failed", description: "The server hasn't successfully fulfilled the request from endpoint: \(url). Status code: \(statusCode)")))
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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(PurchaseInformationRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url)")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetPurchasesRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url)")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetPurchasesRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url)")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetPurchasesRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url)")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
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
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url)", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        if let data = data, let findResult = String(data: data, encoding: .utf8) {
                            completion(.success(findResult))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Unable to retrieve the developer’s public key", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
}
