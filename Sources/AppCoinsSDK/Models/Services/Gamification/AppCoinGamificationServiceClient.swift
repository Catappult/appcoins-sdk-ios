//
//  AppCoinGamificationServiceClient.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal class AppCoinGamificationServiceClient : AppCoinGamificationService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.gamificationServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func getTransactionBonus(wallet: Wallet, package_name: String, amount: String, currency: Currency, result: @escaping (Result<TransactionBonusRaw, TransactionError>) -> Void) {
        let route = "/bonus_forecast"
        if let url = URL(string: endpoint + route + "?address=\(wallet.getWalletAddress())&package_name=\(package_name)&amount=\(amount)&currency=\(currency.currency)") {
            
            var request = URLRequest(url: url)
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed()))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(TransactionBonusRaw.self, from: data) {
                        result(.success(findResult))
                    } else { result(.failure(.failed())) }
                }
            }
            task.resume()
        }
    }
}
