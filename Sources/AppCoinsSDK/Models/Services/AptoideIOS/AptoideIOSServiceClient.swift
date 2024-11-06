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
            
            var request = URLRequest(url: url)
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AptoideIOSServiceClient.swift:isWalletAvailable", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AptoideIOSServiceClient.swift:isWalletAvailable", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        result(.success(httpResponse.statusCode == 200)) }
                    else if let httpResponse = response as? HTTPURLResponse {
                        result(.failure(.failed(message: "Service Failed", description: "The request to the server failed on endpoint: \(url), with status code: \(httpResponse.statusCode) at AptoideIOSServiceClient.swift:isWalletAvailable", request: nil)))
                    }
                }
            }
            task.resume()
        }
    }
    
}
