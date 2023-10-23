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

    internal func convertCurrency(money: String, fromCurrency: Coin, toCurrency: Coin, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void) {
        let route = "/exchanges/"
        if let url = URL(string: endpoint + route + "\(fromCurrency.rawValue)/convert/\(money)?to=\(toCurrency.rawValue)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
    
    internal func getPaymentMethods(value: String, currency: Coin, result: @escaping (Result<GetPaymentMethodsRaw, BillingError>) -> Void) {
        let route = "/methods"
        if let url = URL(string: endpoint + route + "?price.value=\(value)&price.currency=\(currency.rawValue)&channel=IOS") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
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

    internal func createTransaction(wa: Wallet, raw: CreateAPPCTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void) {
        let route = "/gateways/appcoins_credits/transactions"
        if let url = URL(string: endpoint + route) {
            if let body = raw.toJSON() {

                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "authorization")
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
                            if let txResponse = try? JSONDecoder().decode(CreateTransactionResponseRaw.self, from: data) {
                                completion(.success(txResponse))
                            } else {
                                if let errorResponse = try? JSONDecoder().decode(CreateTransactionErrorRaw.self, from: data) {
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
    
    internal func transferAPPC(wa: Wallet, raw: TransferAPPCRaw, completion: @escaping (Result<TransferAPPCResponseRaw, TransactionError>) -> Void) {
        let route = "/gateways/appcoins_credits/transactions?wallet.address=\(wa.getWalletAddress())"
        if let url = URL(string: endpoint + route) {
            if let body = raw.toJSON() {

                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "authorization")
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
                                if let errorResponse = try? JSONDecoder().decode(CreateTransactionErrorRaw.self, from: data) {
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
    
    internal func getTransactionInfo(uid: String, wa: Wallet, completion: @escaping (Result<GetTransactionInfoRaw, TransactionError>) -> Void) {
        let route = "/transactions/\(uid)"
        if let url = URL(string: endpoint + route) {
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10
            
            var request = URLRequest(url: url)
            
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "authorization")
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
    
    internal func createAdyenTransaction(wa: Wallet, raw: CreateAdyenTransactionRaw, completion: @escaping (Result<CreateAdyenTransactionResponseRaw, TransactionError>) -> Void) {
        
        let route = "/gateways/adyen_v2/session"
        if let url = URL(string: endpoint + route) {
            if let body = raw.toJSON() {
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "authorization")
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
    
    internal func createBAPayPalTransaction(wa: Wallet, raw: CreateBAPayPalTransactionRaw, completion: @escaping (Result<CreateBAPayPalTransactionResponseRaw, TransactionError>) -> Void) {
        
        // Magnes SDK integration will only be used when we're no longer using Jailbreak
//        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/transactions"
        if let url = URL(string: endpoint + route) {
            if let body = raw.toJSON() {

                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "authorization")
                }
                
                // Magnes SDK integration will only be used when we're no longer using Jailbreak
//                request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
                
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
    
    internal func createBillingAgreementToken(wa: Wallet, raw: CreateBillingAgreementTokenRaw, completion: @escaping (Result<CreateBillingAgreementTokenResponseRaw, TransactionError>) -> Void) {
        
        // Magnes SDK integration will only be used when we're no longer using Jailbreak
//        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/token/create"
        if let url = URL(string: endpoint + route) {
            if let body = raw.toJSON() {

                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"
                
                if let ewt = wa.getEWT() {
                    request.setValue(ewt, forHTTPHeaderField: "authorization")
                }
                
                // Magnes SDK integration will only be used when we're no longer using Jailbreak
//                request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
                
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
        
        // Magnes SDK integration will only be used when we're no longer using Jailbreak
//        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/token/cancel"
        if let url = URL(string: endpoint + route) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "\"\(token)\"".data(using: .utf8)
            request.httpMethod = "POST"
            
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "authorization")
            }
            
            // Magnes SDK integration will only be used when we're no longer using Jailbreak
//            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
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
        
        // Magnes SDK integration will only be used when we're no longer using Jailbreak
//        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/cancel"
        if let url = URL(string: endpoint + route) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "authorization")
            }
            
            // Magnes SDK integration will only be used when we're no longer using Jailbreak
//            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
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
        
        // Magnes SDK integration will only be used when we're no longer using Jailbreak
//        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement/create"
        if let url = URL(string: endpoint + route) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "\"\(token)\"".data(using: .utf8)
            request.httpMethod = "POST"

            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "authorization")
            }
            
            // Magnes SDK integration will only be used when we're no longer using Jailbreak
//            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
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
        
        // Magnes SDK integration will only be used when we're no longer using Jailbreak
//        let paypalClientMetadataID = Utils.getMagnesSDKClientMetadataID()
        
        let route = "/gateways/paypal/billing-agreement"
        if let url = URL(string: endpoint + route) {
            
            var request = URLRequest(url: url)
        
            if let ewt = wa.getEWT() {
                request.setValue(ewt, forHTTPHeaderField: "authorization")
            }
            
            // Magnes SDK integration will only be used when we're no longer using Jailbreak
//            request.setValue(paypalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
            
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
    
}
