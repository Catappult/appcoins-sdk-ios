//
//  File.swift
//  
//
//  Created by aptoide on 28/11/2024.
//

import Foundation

internal class AuthClient : AuthService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.aptoideWebservicesBaseURL) {
        self.endpoint = endpoint
    }
    
    internal func loginWithGoogle(code: String, completion: @escaping (Result<LoginWithMagicLinkResponseRaw, AuthError>) -> Void) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/user/authorize"
            
            if let url = urlComponents.url {
                if let body = UserAuthRaw.fromGoogleAuth(code: code).toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    print(url)
                    print(String(data: body, encoding: .utf8))
                    
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AuthClient.swift:loginWithGoogle", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AuthClient.swift:loginWithGoogle", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    print(String(data: data, encoding: .utf8))
                                    let successResponse = try JSONDecoder().decode(LoginWithMagicLinkResponseRaw.self, from: data)
                                    completion(.success(successResponse))
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AuthClient.swift:loginWithGoogle")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AuthClient.swift:loginWithGoogle", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
    
    internal func loginWithMagicLink(code: String, state: String, completion: @escaping (Result<LoginWithMagicLinkResponseRaw, AuthError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/user/authorize"
            
            if let url = urlComponents.url {
                if let body = UserAuthRaw.fromMagicLinkCode(code: code, state: state).toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AuthClient.swift:loginWithMagicLink", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AuthClient.swift:loginWithMagicLink", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    print(String(data: data, encoding: .utf8))
                                    let successResponse = try JSONDecoder().decode(LoginWithMagicLinkResponseRaw.self, from: data)
                                    completion(.success(successResponse))
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AuthClient.swift:loginWithMagicLink")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AuthClient.swift:loginWithMagicLink", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }

    internal func sendMagicLink(email: String, completion: @escaping (Result<SendMagicLinkResponseRaw, AuthError>) -> Void) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/user/authorize"
            
            if let url = urlComponents.url {
                if let body = UserAuthRaw.fromMagicLinkEmail(email: email).toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                        
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                                completion(.failure(.noInternet(message: "Internet Connection Failed", description: "Could not get internet connection to \(url) at AuthClient.swift:sendMagicLink", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            } else {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to communicate with service on endpoint: \(url) at AuthClient.swift:sendMagicLink", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        } else {
                            do {
                                if let data = data {
                                    let successResponse = try JSONDecoder().decode(SendMagicLinkResponseRaw.self, from: data)
                                    completion(.success(successResponse))
                                } else {
                                    completion(.failure(.failed(message: "Service Failed", description: "No data received from endpoint: \(url) at AuthClient.swift:sendMagicLink")))
                                }
                            } catch {
                                completion(.failure(.failed(message: "Service Failed", description: "Failed to decode response from endpoint: \(url). Error: \(error.localizedDescription) at AuthClient.swift:sendMagicLink", request: DebugRequestInfo(request: request, responseData: data, response: response))))
                            }
                        }
                    })
                    task.resume()
                }
            }
        }
    }
}