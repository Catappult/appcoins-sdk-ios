//
//  AppCoinBillingClient.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

internal class AppCoinBillingClient : AppCoinBillingService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.billingServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func convertCurrency(money: String, fromCurrency: Currency, toCurrency: Currency?, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/exchanges/\(fromCurrency.currency)/convert/\(money)"
            
            urlComponents.queryItems = []
            if let toCurrency = toCurrency?.currency {
                urlComponents.queryItems?.append( URLQueryItem(name: "to", value: toCurrency) )
            }
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:convertCurrency", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:convertCurrency", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(ConvertCurrencyRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:convertCurrency")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:convertCurrency", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    internal func getSupportedCurrencies(result: @escaping (Result<[CurrencyRaw], BillingError>) -> Void) {
        var currencies: [CurrencyRaw] = []
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/currencies"
            urlComponents.queryItems = [
                URLQueryItem(name: "type", value: "FIAT"),
                URLQueryItem(name: "icon.height", value: "128")
            ]
            
            if let url = urlComponents.url {
                
                func getNextCurrenciesBatch(url: URL) {
                    var request = URLRequest(url: url)
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    request.httpMethod = "GET"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 10
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:getSupportedCurrencies", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:getSupportedCurrencies", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let findResult = try JSONDecoder().decode(CurrencyListRaw.self, from: data)
                                    
                                    currencies.append(contentsOf: findResult.items)
                                    
                                    if let nextString = findResult.next?.url, let nextURL = URL(string: nextString) {
                                        getNextCurrenciesBatch(url: nextURL)
                                    } else {
                                        result(.success(currencies))
                                    }
                                    
                                } else {
                                    result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:getSupportedCurrencies")))
                                }
                            } catch {
                                result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:getSupportedCurrencies", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    }
                    task.resume()
                }
                getNextCurrenciesBatch(url: url)
            }
        }
    }
}
