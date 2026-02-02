//
//  SDKServiceClient.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation

@available(iOS 26.0, *)
internal class SDKServiceClient : SDKService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.iOSSDKServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func record(body: RecordTokenRaw, result: @escaping (Result<Bool, SDKServiceError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/reports/record"
            
            if let url = urlComponents.url {
                var request = URLRequest(url: url)
                
                guard let jsonData = try? JSONEncoder().encode(body) else {
                    result(.failure(.failed(message: "Invalid Request Body", description: "Invalid Request Body when generating request body at SDKClient.swift:record", request: DebugRequestInfo(request: request, responseData: nil, response: nil))))
                    return
                }
                
                let userAgent = "AppCoinsWalletIOS/.."
                request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                
                request.httpMethod = "PUT"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 20
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                            result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at SDKClient.swift:record", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at SDKClient.swift:record", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        }
                    } else if let httpResponse = response as? HTTPURLResponse {
                        if (200...299).contains(httpResponse.statusCode) {
                            result(.success(true))
                        } else if httpResponse.statusCode == 500 {
                            result(.failure(.failed(message: "Service Failed", description: "Server returned status code \(httpResponse.statusCode) at SDKClient.swift:record", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                        } else {
                            Utils.log("Notified service about External Purchase Token but service could not process it.")
                            result(.success(false))
                        }
                    } else {
                        result(.failure(.failed(message: "Invalid Response", description: "No valid HTTP response at SDKClient.swift:record", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                }
                task.resume()
            }
        }
    }
}
