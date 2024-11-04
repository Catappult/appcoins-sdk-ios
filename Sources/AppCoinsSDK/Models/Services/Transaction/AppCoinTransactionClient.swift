//
//  AppCoinTransactionClient.swift
//
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal class AppCoinTransactionClient : AppCoinTransactionService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.transactionServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func getBalance(wallet: Wallet, currency: Currency, result: @escaping (Result<AppCoinBalanceRaw, AppcTransactionError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/1.20230807/wallet/\(wallet.getWalletAddress())/info"
            
            urlComponents.queryItems = [URLQueryItem(name: "currency", value: currency.currency)]
            
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
                                let findResult = try JSONDecoder().decode(AppCoinBalanceRaw.self, from: data)
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
    
}
