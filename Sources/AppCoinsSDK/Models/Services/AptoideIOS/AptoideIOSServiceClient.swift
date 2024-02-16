//
//  AptoideIOSServiceClient.swift
//
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal class AptoideIOSServiceClient : AptoideIOSService {

    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.aptoideIosServiceURL) {
        self.endpoint = endpoint
    }
    
    func isWalletAvailable(result: @escaping (Result<Bool, AptoideIOSServiceError>) -> Void) {
        let route = "/applications"
        let package = "com.aptoide.appcoins-wallet"
        if let url = URL(string: endpoint + route + "/\(package)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse { result(.success(httpResponse.statusCode == 200)) }
                    else { result(.failure(.failed)) }
                }
                
            }
            task.resume()
        }
    }
    
}
