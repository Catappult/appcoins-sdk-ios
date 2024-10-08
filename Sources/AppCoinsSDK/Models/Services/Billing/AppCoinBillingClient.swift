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
                            result(.failure(.noInternet))
                        } else {
                            result(.failure(.failed))
                        }
                    } else {
                        if let data = data, let convertion = try? JSONDecoder().decode(ConvertCurrencyRaw.self, from: data) {
                            result(.success(convertion))
                        } else { result(.failure(.failed)) }
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
                            result(.failure(.noInternet))
                        } else {
                            result(.failure(.failed))
                        }
                    } else {
                        if let data = data, let convertion = try? JSONDecoder().decode(GetPaymentMethodsRaw.self, from: data) {
                            result(.success(convertion))
                        } else { result(.failure(.failed)) }
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
                    
                    if let ewt = wa.getEWT() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet))
                            } else {
                                completion(.failure(.failed()))
                            }
                        } else {
                            if let data = data {
                                if let txResponse = try? JSONDecoder().decode(TransferAPPCResponseRaw.self, from: data) {
                                    completion(.success(txResponse))
                                } else {
                                    if let errorResponse = try? JSONDecoder().decode(TransferAPPCTransactionErrorRaw.self, from: data) {
                                        completion(.failure(.failed(description: errorResponse.data.enduser)))
                                    } else {
                                        completion(.failure(.general))
                                    }
                                }
                            } else {
                                completion(.failure(.general))
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
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                let task = URLSession(configuration: configuration).dataTask(with: request) { data, response, error in
                    
                    if let error = error {
                        if let nsError = error as NSError? {
                            if nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet))
                            } else if nsError.code == NSURLErrorTimedOut {
                                completion(.failure(.timeOut))
                            } else {
                                completion(.failure(.failed()))
                            }
                        } else {
                            completion(.failure(.failed()))
                        }
                    } else {
                        if let data = data, let txResponse = try? JSONDecoder().decode(GetTransactionInfoRaw.self, from: data) {
                            completion(.success(txResponse))
                        } else {
                            completion(.failure(.failed()))
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
                    
                    if let ewt = wa.getEWT() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet))
                            } else {
                                completion(.failure(.failed()))
                            }
                        } else {
                            if let data = data {
                                if let txResponse = try? JSONDecoder().decode(CreateAPPCTransactionResponseRaw.self, from: data) {
                                    completion(.success(txResponse))
                                } else {
                                    if let errorResponse = try? JSONDecoder().decode(CreateAPPCTransactionErrorRaw.self, from: data) {
                                        completion(.failure(.failed(description: errorResponse.data.enduser)))
                                    } else {
                                        completion(.failure(.general))
                                    }
                                }
                            } else {
                                completion(.failure(.general))
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
                    
                    if let ewt = wa.getEWT() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet))
                            } else {
                                completion(.failure(.failed()))
                            }
                        } else {
                            if let data = data {
                                if let txResponse = try? JSONDecoder().decode(CreateSandboxTransactionResponseRaw.self, from: data) {
                                    completion(.success(txResponse))
                                } else {
                                    if let errorResponse = try? JSONDecoder().decode(CreateSandboxTransactionErrorRaw.self, from: data) {
                                        completion(.failure(.failed(description: errorResponse.data.enduser)))
                                    } else {
                                        completion(.failure(.general))
                                    }
                                }
                            } else {
                                completion(.failure(.general))
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
                    
                    if let ewt = wa.getEWT() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet))
                            } else {
                                completion(.failure(.failed()))
                            }
                        } else {
                            if let data = data {
                                if let successResponse = try? JSONDecoder().decode(CreateAdyenTransactionResponseRaw.self, from: data) {
                                    completion(.success(successResponse))
                                } else {
                                    completion(.failure(.failed()))
                                }
                            } else {
                                completion(.failure(.failed()))
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
                    
                    if let ewt = wa.getEWT() {
                        request.setValue(ewt, forHTTPHeaderField: "Authorization")
                    }
                    
                    // Magnes SDK integration
                    request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
                    
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet))
                            } else {
                                completion(.failure(.failed()))
                            }
                        } else {
                            if let data = data {
                                if let successResponse = try? JSONDecoder().decode(CreateBAPayPalTransactionResponseRaw.self, from: data) {
                                    completion(.success(successResponse))
                                } else if let BANotFounResponse = try? JSONDecoder().decode(CreateBAPayPalBillingAgreementNotFoundResponseRaw.self, from: data) {
                                    if BANotFounResponse.code == "Paypal.BillingAgreement.NotFound" {
                                        completion(.failure(.noBillingAgreement))
                                    } else {
                                        completion(.failure(.failed()))
                                    }
                                } else {
                                    completion(.failure(.failed()))
                                }
                            } else {
                                completion(.failure(.failed()))
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
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "Authorization")
                }
                
                // Magnes SDK integration
                request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
                
                // Right now not giving feedback on different types of errors
                let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            completion(.failure(.noInternet))
                        } else {
                            completion(.failure(.failed()))
                        }
                    } else {
                        if let data = data, let successResponse = try? JSONDecoder().decode(CreateBillingAgreementTokenResponseRaw.self, from: data) {
                                completion(.success(successResponse))
                        } else {
                            completion(.failure(.failed()))
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
            
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed()))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode == 204 {
                            completion(.success(true))
                        } else {
                            completion(.failure(.failed()))
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
            
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed()))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode == 204 {
                            completion(.success(true))
                        } else {
                            completion(.failure(.failed()))
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

            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed()))
                    }
                } else {
                    if let data = data, let successResponse = try? JSONDecoder().decode(CreateBillingAgreementResponseRaw.self, from: data) {
                            completion(.success(successResponse))
                    } else {
                        completion(.failure(.failed()))
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
        
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "Authorization")
            }
            
            // Magnes SDK integration
            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
                    } else {
                        completion(.failure(.failed()))
                    }
                } else {
                    if let data = data, let _ = try? JSONDecoder().decode(GetBillingAgreementResponseRaw.self, from: data) {
                            completion(.success(true))
                    } else if let data = data, let _ = try? JSONDecoder().decode(GetBillingAgreementNotFoundResponseRaw.self, from: data) {
                        completion(.success(false))
                    } else {
                        completion(.failure(.failed()))
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
                                result(.failure(.noInternet))
                            } else {
                                result(.failure(.failed))
                            }
                        } else {
                            if let data = data, let findResult = try? JSONDecoder().decode(CurrencyListRaw.self, from: data) {
                                
                                currencies.append(contentsOf: findResult.items)
                                
                                if let nextString = findResult.next?.url, let nextURL = URL(string: nextString) {
                                    getNextCurrenciesBatch (url: nextURL)
                                } else {
                                    result(.success(currencies))
                                }
                            } else {
                                result(.failure(.failed))
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
