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
    
    internal func authenticate(token: String) {
        
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.path += "/user/authorize"
            
            if let url = urlComponents.url {
                if let body = UserAuthRaw.fromGoogleAuth(token: token).toJSON() {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    print(String(data: body, encoding: .utf8))
                                        
                    // Right now not giving feedback on different types of errors
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                        
                        if let error = error {
                            print("Error: \(error)")
                        } else {
                            print("Data: \(String(data: data!, encoding: .utf8))")
                        }
                    })
                    task.resume()
                }
            }
        }
    }
}
