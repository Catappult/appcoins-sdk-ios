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
                            result(.failure(.noInternet))
                        } else {
                            result(.failure(.failed))
                        }
                    } else {
                        if let data = data, let balance = try? JSONDecoder().decode(AppCoinBalanceRaw.self, from: data) {
                            result(.success(balance))
                        } else { result(.failure(.failed)) }
                    }
                }
                task.resume()
            }
        }
    }
    
}
