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
                        result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AppCoinGamificationServiceClient.swift:getTransactionBonus")))
                    } else {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AppCoinGamificationServiceClient.swift:getTransactionBonus")))
                    }
                } else {
                    do {
                        if let data = data {
                            print(String(data: data, encoding: .utf8))
                            let successResponse = try JSONDecoder().decode(TransactionBonusRaw.self, from: data)
                            result(.success(successResponse))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AppCoinGamificationServiceClient.swift:getTransactionBonus")))
                        }
                    } catch {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AppCoinGamificationServiceClient.swift:getTransactionBonus", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                }
            }
            task.resume()
        }
    }
}
