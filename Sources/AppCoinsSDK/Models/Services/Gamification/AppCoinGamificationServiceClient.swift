//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

class AppCoinGamificationServiceClient : AppCoinGamificationService {
    
    private let endpoint: String
    
    init(endpoint: String = "https://apichain.dev.catappult.io/gamification") {
        self.endpoint = endpoint
    }
    
    func getTransactionBonus(address: String, package_name: String, amount: String, currency: Coin, result: @escaping (Result<TransactionBonusRaw, TransactionError>) -> Void) {
        let route = "/bonus_forecast"
        if let url = URL(string: endpoint + route + "?address=\(address)&package_name=\(package_name)&amount=\(amount)&currency=\(currency.rawValue)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
