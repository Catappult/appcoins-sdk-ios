//
//  AptoideServiceClient.swift
//  
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal class AptoideServiceClient : AptoideService {

    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.aptoideServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func getDeveloperWalletAddressByPackageName(package: String, result: @escaping (Result<FindDeveloperWalletAddressRaw, AptoideServiceError>) -> Void) {
        let route = "/bds/apks/package/getOwnerWallet"
        if let url = URL(string: endpoint + route + "/package_name=\(package)") {
            
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
                    if let data = data, let findResult = try? JSONDecoder().decode(FindDeveloperWalletAddressRaw.self, from: data) {
                        result(.success(findResult))
                    } else { result(.failure(.failed)) }
                }
                
            }
            task.resume()
        }
    }
    
}
