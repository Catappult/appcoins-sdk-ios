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
    
    internal func getPaymentMethods(value: String, currency: Currency, wallet: Wallet, domain: String, result: @escaping (Result<GetPaymentMethodsRaw, BillingError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/methods"
            urlComponents.queryItems = [
                URLQueryItem(name: "domain", value: domain),
                URLQueryItem(name: "wallet.address", value: wallet.getWalletAddress()),
                URLQueryItem(name: "price.value", value: value),
                URLQueryItem(name: "price.currency", value: currency.currency),
                URLQueryItem(name: "channel", value: "IOS")
            ]
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:getPaymentMethods", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:getPaymentMethods", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let findResult = try JSONDecoder().decode(GetPaymentMethodsRaw.self, from: data)
                                result(.success(findResult))
                            } else {
                                result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:getPaymentMethods")))
                            }
                        } catch {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:getPaymentMethods", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    internal func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/gateways/appcoins_credits/transactions"
            urlComponents.queryItems = [
                URLQueryItem(name: "wallet.address", value: wa.getWalletAddress())
            ]
            
            if let url = urlComponents.url {
                
                if let body = raw.toJSON() {
                    
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    if let token = wa.getAuthToken() {
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:transferAPPC", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:transferAPPC", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    do {
                                        let txResponse = try JSONDecoder().decode(TransferAPPCResponseRaw.self, from: data)
                                        completion(.success(txResponse))
                                    } catch let error as DecodingError {
                                        do {
                                            let errorResponse = try JSONDecoder().decode(TransferAPPCTransactionErrorRaw.self, from: data)
                                            completion(.failure(.failed(message: "Service Failed", description: "Failed to comunicate with service on endpoint: \(url). Error description: \(errorResponse.data.enduser) at AppCoinBillingClient.swift:transferAPPC", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        } catch {
                                            completion(.failure(.general(message: "Service Failed", description: "Failed to decode error from endpoint: \(url) at AppCoinBillingClient.swift:transferAPPC", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        }
                                    }
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:transferAPPC")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:transferAPPC", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
    internal func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<GetTransactionInfoRaw, TransactionError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/transactions/\(uid)"
            
            if let url = urlComponents.url {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 10
                
                var request = URLRequest(url: url)
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                if let token = wa.getAuthToken() {
                    request.setValue(token, forHTTPHeaderField: "Authorization")
                }
                
                let task = URLSession(configuration: configuration).dataTask(with: request) { data, response, error in
                    
                    if let error = error {
                        if let nsError = error as NSError? {
                            if nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:getTransactionInfo", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else if nsError.code == NSURLErrorTimedOut {
                                completion(.failure(.timeOut(message: "Service Failed", description: "The request timed out on endpoint: \(url) at AppCoinBillingClient.swift:getTransactionInfo", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:getTransactionInfo", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:getTransactionInfo", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let txResponse = try JSONDecoder().decode(GetTransactionInfoRaw.self, from: data)
                                completion(.success(txResponse))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:getTransactionInfo")))
                            }
                        } catch {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:getTransactionInfo", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    internal func createAPPCTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateAPPCTransactionResponseRaw, TransactionError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/gateways/appcoins_credits/transactions"
            
            if let url = urlComponents.url {
                if let body = raw.toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    if let token = wa.getAuthToken() {
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:createAPPCTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:createAPPCTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    do {
                                        let txResponse = try JSONDecoder().decode(CreateAPPCTransactionResponseRaw.self, from: data)
                                        completion(.success(txResponse))
                                    } catch let error as DecodingError {
                                        do {
                                            let errorResponse = try JSONDecoder().decode(CreateAPPCTransactionErrorRaw.self, from: data)
                                            completion(.failure(.failed(message: "Service Failed", description: "Failed to comunicate with service on endpoint: \(url). Error description: \(errorResponse.data.enduser) at AppCoinBillingClient.swift:createAPPCTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        } catch {
                                            completion(.failure(.general(message: "Service Failed", description: "Failed to decode error from endpoint: \(url) at AppCoinBillingClient.swift:createAPPCTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        }
                                    }
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:createAPPCTransaction")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:createAPPCTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
    internal func createSandboxTransaction(wa: Wallet, raw: CreateSandboxTransactionRaw, completion: @escaping (Result<CreateSandboxTransactionResponseRaw, TransactionError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/gateways/sandbox/transactions"
            
            if let url = urlComponents.url {
                if let body = raw.toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    if let token = wa.getAuthToken() {
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:createSandboxTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:createSandboxTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    do {
                                        let txResponse = try JSONDecoder().decode(CreateSandboxTransactionResponseRaw.self, from: data)
                                        completion(.success(txResponse))
                                    } catch let error as DecodingError {
                                        do {
                                            let errorResponse = try JSONDecoder().decode(CreateSandboxTransactionErrorRaw.self, from: data)
                                            completion(.failure(.failed(message: "Service Failed", description: "Failed to comunicate with service on endpoint: \(url). Error description: \(errorResponse.data.enduser) at AppCoinBillingClient.swift:createSandboxTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        } catch {
                                            completion(.failure(.general(message: "Service Failed", description: "Failed to decode error from endpoint: \(url) at AppCoinBillingClient.swift:createSandboxTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        }
                                    }
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:createSandboxTransaction")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:createSandboxTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
    internal func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<CreateAdyenTransactionResponseRaw, TransactionError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/gateways/adyen_v2/session"
            
            if let url = urlComponents.url {
                if let body = raw.toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    if let token = wa.getAuthToken() {
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:createAdyenTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:createAdyenTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let successResponse = try JSONDecoder().decode(CreateAdyenTransactionResponseRaw.self, from: data)
                                    completion(.success(successResponse))
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:createAdyenTransaction")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:createAdyenTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
    internal func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void) {
        
        // Magnes SDK integration
        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/gateways/paypal/transactions"
            
            if let url = urlComponents.url {
                if let body = raw.toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let userAgent = "AppCoinsWalletIOS/.."
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    
                    if let token = wa.getAuthToken() {
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Magnes SDK integration
                    request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:createBAPayPalTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:createBAPayPalTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    do {
                                        let successResponse = try JSONDecoder().decode(CreateBAPayPalTransactionResponseRaw.self, from: data)
                                        completion(.success(successResponse))
                                    } catch let error as DecodingError {
                                        do {
                                            let BANotFounResponse = try JSONDecoder().decode(CreateBAPayPalBillingAgreementNotFoundResponseRaw.self, from: data)
                                            if BANotFounResponse.code == "Paypal.BillingAgreement.NotFound" {
                                                completion(.failure(.noBillingAgreement(message: "Service Failed", description: "Paypal billing agreement Not Found on endpoint: \(url) at AppCoinBillingClient.swift:createBAPayPalTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                            } else {
                                                completion(.failure(.failed(message: "Service Failed", description: "Billing agreement Not Found from endpoint: \(url). BANotFounResponse code: \(BANotFounResponse.code) at AppCoinBillingClient.swift:createBAPayPalTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                            }
                                        } catch {
                                            completion(.failure(.general(message: "Service Failed", description: "Failed to decode error from endpoint: \(url) at AppCoinBillingClient.swift:createBAPayPalTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                        }
                                    }
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:createBAPayPalTransaction")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:createBAPayPalTransaction", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
    internal func createBillingAgreementToken(wa: Wallet, raw: CreateBillingAgreementTokenRaw, completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void) {
        
        // Magnes SDK integration
        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/token/create"
        if let url = URL(string: endpoint + route) {
            if let body = raw.toJSON() {
                
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                if let token = wa.getAuthToken() {
                    request.setValue(token, forHTTPHeaderField: "Authorization")
                }
                
                // Magnes SDK integration
                request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
                
                // Right now not giving feedback on different types of errors
                let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:createBillingAgreementToken", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:createBillingAgreementToken", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else {
                        do {
                            if let data = data {
                                let successResponse = try JSONDecoder().decode(CreateBillingAgreementTokenResponseRaw.self, from: data)
                                completion(.success(successResponse))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:createBillingAgreementToken")))
                            }
                        } catch {
                            completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:createBillingAgreementToken", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    }
                })
                task.resume()
            }
        }
    }
    
    internal func cancelBillingAgreementToken(token: String, wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        
        // Magnes SDK integration
        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/token/cancel"
        if let url = URL(string: endpoint + route) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "\"\(token)\"".data(using: .utf8)
            request.httpMethod = "POST"
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            if let token = wa.getAuthToken() {
                request.setValue(token, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:cancelBillingAgreementToken", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:cancelBillingAgreementToken", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode == 204 {
                            completion(.success(true))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Unable to cancel the billing agreement token on endpoint: \(url), with status code: \(httpResponse.statusCode) at AppCoinBillingClient.swift:cancelBillingAgreementToken", request: nil)))
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    internal func cancelBillingAgreement(wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        
        // Magnes SDK integration
        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/cancel"
        if let url = URL(string: endpoint + route) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            if let token = wa.getAuthToken() {
                request.setValue(token, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:cancelBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:cancelBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode == 204 {
                            completion(.success(true))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "Unable to cancel the billing agreement on endpoint: \(url), with status code: \(httpResponse.statusCode) at AppCoinBillingClient.swift:cancelBillingAgreement", request: nil)))
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    internal func createBillingAgreement(token: String, wa: Wallet, completion: @escaping (Result<CreateBillingAgreementResponseRaw, TransactionError>) -> Void) {
        
        // Magnes SDK integration
        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/create"
        if let url = URL(string: endpoint + route) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "\"\(token)\"".data(using: .utf8)
            request.httpMethod = "POST"
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            if let token = wa.getAuthToken() {
                request.setValue(token, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:createBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:createBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    do {
                        if let data = data {
                            let successResponse = try JSONDecoder().decode(CreateBillingAgreementResponseRaw.self, from: data)
                            completion(.success(successResponse))
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:createBillingAgreement")))
                        }
                    } catch {
                        completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:createBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                }
            })
            task.resume()
        }
    }
    
    internal func getBillingAgreement(wa: Wallet, completion: @escaping (Result<Bool, TransactionError>) -> Void) {
        
        // Magnes SDK integration
        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement"
        if let url = URL(string: endpoint + route) {
            
            var request = URLRequest(url: url)
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            if let token = wa.getAuthToken() {
                request.setValue(token, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinBillingClient.swift:getBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinBillingClient.swift:getBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    do {
                        if let data = data {
                            do {
                                let _ = try JSONDecoder().decode(GetBillingAgreementResponseRaw.self, from: data)
                                completion(.success(true))
                            } catch let error as DecodingError {
                                do {
                                    let _ = try JSONDecoder().decode(GetBillingAgreementNotFoundResponseRaw.self, from: data)
                                    completion(.success(false))
                                } catch {
                                    completion(.failure(.general(message: "Service Failed", description: "Failed to decode error from endpoint: \(url) at AppCoinBillingClient.swift:getBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                                }
                            }
                        } else {
                            completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinBillingClient.swift:getBillingAgreement")))
                        }
                    } catch {
                        completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinBillingClient.swift:getBillingAgreement", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                }
            })
            task.resume()
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
