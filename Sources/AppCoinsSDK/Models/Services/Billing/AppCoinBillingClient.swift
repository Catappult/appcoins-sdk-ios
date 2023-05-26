//
//  File.swift
//  
//
//  Created by aptoide on 15/05/2023.
//

import Foundation

class AppCoinBillingClient : AppCoinBillingService {

    private let endpoint: String
    
    init(endpoint: String = "https://api.dev.catappult.io/broker") {
        self.endpoint = endpoint
    }

    func convertCurrency(money: String, fromCurrency: Coin, toCurrency: Coin, result: @escaping (Result<ConvertCurrencyRaw, BillingError>) -> Void) {
        let route = "/8.20200810/exchanges/"
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
    
    func getPaymentMethods(value: String, currency: Coin, result: @escaping (Result<GetPaymentMethodsRaw, BillingError>) -> Void) {
        let route = "/8.20200810/methods"
        if let url = URL(string: endpoint + route + "?price.value=\(value)&price.currency=\(currency.rawValue)") {
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

    func createTransaction(wa: String, waSignature: String, raw: CreateTransactionRaw, completion: @escaping (Result<CreateTransactionResponseRaw, TransactionError>) -> Void) {
        let route = "/8.20200810/gateways/appcoins_credits/transactions"
        if let url = URL(string: endpoint + route + "?wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            if let body = raw.toJSON() {

                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                request.httpMethod = "POST"

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
    
    func getTransactionInfo(uid: String, wa: String, waSignature: String, completion: @escaping (Result<GetTransactionInfoRaw, TransactionError>) -> Void) {
        let route = "/8.20200810/transactions/\(uid)"
        if let url = URL(string: endpoint + route + "?wallet.address=\(wa)&wallet.signature=\(waSignature)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternet))
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
