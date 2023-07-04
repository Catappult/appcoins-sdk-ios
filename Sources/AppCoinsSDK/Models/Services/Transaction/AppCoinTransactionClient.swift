//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

class AppCoinTransactionClient : AppCoinTransactionService {
    
    private let endpoint: String
    
    init(endpoint: String = BuildConfiguration.transactionServiceURL) {
        self.endpoint = endpoint
    }
    
    func getBalance(wa: String, result: @escaping (Result<AppCoinBalanceRaw, AppcTransactionError>) -> Void) {
        if let url = URL(string: endpoint + "/wallet/\(wa)/info") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
