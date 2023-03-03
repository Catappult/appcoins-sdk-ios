//
//  BillingClient.swift
//  appcoins-sdk
//
//  Created by aptoide on 02/03/2023.
//

import Foundation

class BillingClient : BillingService {
    
    private let endpoint: String
    
    init(endpoint: String = BuildConfiguration.baseURL + "/inapp/8.20180518/packages") {
        self.endpoint = endpoint
    }
    
    func getPurchases(packageName: String, walletAddress: String, walletSignature: String, type: String) {

        let requestURL = URL(string: endpoint + "/\(packageName)/purchases?wallet.address=\(walletAddress)&wallet.signature=\(walletSignature)&type=\(type)")

        if let requestURL = requestURL {
            var request = URLRequest(url: requestURL)
            
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    // TO DO
                }
                
//                if let data = data, let findResult = try? JSONDecoder().decode(AppListRaw.self, from: data) {
//                    result(findResult, nil)
//                } else {
//                    if let httpResponse = response as? HTTPURLResponse {
//                        let statusCode = httpResponse.statusCode
//                        result(nil, AptoideError.generalError(code: statusCode, title: "Error", message: "Something went wrong."))
//                    }
//                }
            }
            task.resume()
        }
        
    }
}
