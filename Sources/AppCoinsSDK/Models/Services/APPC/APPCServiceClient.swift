//
//  APPCServiceClient.swift
//
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal class APPCServiceClient : APPCService {

    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.APPCServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func getGuestWallet(guestUID: String, result: @escaping (Result<GuestWalletRaw, APPCServiceError>) -> Void) {
        let route = "/guest_wallet"
        if let url = URL(string: endpoint + route + "?id=\(guestUID)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(GuestWalletRaw.self, from: data) {
                        result(.success(findResult))
                    } else { result(.failure(.failed)) }
                }
                
            }
            task.resume()
        }
    }
    
}
