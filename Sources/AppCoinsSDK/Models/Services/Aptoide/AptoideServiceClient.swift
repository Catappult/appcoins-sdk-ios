//
//  File.swift
//  
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

class AptoideServiceClient : AptoideService {

    private let endpoint: String
    
    init(endpoint: String = BuildConfiguration.aptoideServiceURL) {
        self.endpoint = endpoint
    }
    
    func getDeveloperWalletAddressByPackageName(package: String, result: @escaping (Result<FindDeveloperWalletAddressRaw, AptoideServiceError>) -> Void) {
        let route = "/bds/apks/package/getOwnerWallet"
        if let url = URL(string: endpoint + route + "/package_name=\(package)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
