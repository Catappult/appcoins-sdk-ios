//
//  PayFlowClient.swift
//  
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal class PayFlowClient: PayFlowService {
    
    private let endpoint: String
    
    init(endpoint: String = BuildConfiguration.payFlowServiceBaseURL) {
        self.endpoint = endpoint
    }
    
    internal func setPayFlow(package: String, packageVercode: String, sdkVercode: Int, locale: String?, oemID: String?, oemIDType: String?, country: String?, os: String, result: @escaping (Result<PayFlowDataRaw, PayFlowError>) -> Void) {
        if let requestUrl = URL(string: "\(endpoint)/api/v2/payment_flow") {
            
            var queryItems = [
                URLQueryItem(name: "package", value: package),
                URLQueryItem(name: "package_vercode", value: packageVercode),
                URLQueryItem(name: "sdk_vercode", value: String(sdkVercode)),
                URLQueryItem(name: "locale", value: locale),
                URLQueryItem(name: "oemid", value: oemID),
                URLQueryItem(name: "oemid_type", value: oemIDType),
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "os", value: os)
            ]
            
            queryItems = queryItems.filter { $0.value != nil }
            var components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            
            guard let url = components?.url else {
                result(.failure(.failed))
                return
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    if let nsError = error as NSError?, nsError.code == NSURLErrorNotConnectedToInternet {
                        result(.failure(.noInternet))
                    } else {
                        result(.failure(.failed))
                    }
                } else {
                    if let data = data, let findResult = try? JSONDecoder().decode(PayFlowDataRaw.self, from: data) {
                        result(.success(findResult))
                    }  else {
                        result(.failure(.failed))
                    }
                }
            }
            task.resume()
        }
    }
}
