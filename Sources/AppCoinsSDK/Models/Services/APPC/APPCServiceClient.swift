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
            
            var request = URLRequest(url: url)
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at APPCServiceClient.swift:getGuestWallet", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at APPCServiceClient.swift:getGuestWallet", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    do {
                        if let data = data {
                            let findResult = try JSONDecoder().decode(GuestWalletRaw.self, from: data)
                            result(.success(findResult))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at APPCServiceClient.swift:getGuestWallet")))
                        }
                    } catch {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at APPCServiceClient.swift:getGuestWallet", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                }
            }
            task.resume()
        }
    }
    
    internal func refreshUserWallet(refreshToken: String, result: @escaping (Result<UserWalletRaw, APPCServiceError>) -> Void) {
        let route = "/user_wallet"
        if let url = URL(string: endpoint + route) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let userAgent = "AppCoinsWalletIOS/.."
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at APPCServiceClient.swift:refreshUserWallet", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    } else {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at APPCServiceClient.swift:refreshUserWallet", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                } else {
                    do {
                        if let data = data {
                            let findResult = try JSONDecoder().decode(UserWalletRaw.self, from: data)
                            Utils.log("Refreshed user wallet with POST successfully")
                            result(.success(findResult))
                        } else {
                            result(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at APPCServiceClient.swift:refreshUserWallet")))
                        }
                    } catch {
                        result(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at APPCServiceClient.swift:refreshUserWallet", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                    }
                }
            }
            task.resume()
        }
    }
}
