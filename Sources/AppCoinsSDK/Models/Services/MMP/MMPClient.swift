//
//  AttributionClient.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal class MMPClient: MMPService {
    
    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.mmpServiceBaseURL) {
        self.endpoint = endpoint
    }
    
    internal func getAttribution(bundleID: String, result: @escaping (Result<AttributionRaw, Error>) -> Void) {
        
        if let requestURL = URL(string: "\(endpoint)/api/v1/attribution?package_name=\(bundleID)") {
            var request = URLRequest(url: requestURL)

            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(nsError))
                    } else {
                        result(.failure(error))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(AttributionRaw.self, from: data) {
                        result(.success(findResult))
                    }  else if let error = error {
                        result(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
}
