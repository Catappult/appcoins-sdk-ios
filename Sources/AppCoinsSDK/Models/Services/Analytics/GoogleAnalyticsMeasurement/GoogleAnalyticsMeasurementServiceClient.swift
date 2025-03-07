//
//  GoogleAnalyticsMeasurementServiceClient.swift
//  
//
//  Created by aptoide on 07/03/2025.
//

import Foundation

internal class GoogleAnalyticsMeasurementServiceClient : GoogleAnalyticsMeasurementService {
    
    private let endpoint: String
    
    private let measurementID: [UInt8] = [50, 68, 102, 117, 105, 108, 70, 121, 98, 103, 55, 88, 111, 89, 52, 115, 120, 51, 83, 65, 107, 57, 80, 72, 55, 48, 67, 121, 119, 68, 75, 71, 97, 52, 81, 70, 76, 85, 77, 100, 83, 79, 56, 61]
    private let measurementKey: [UInt8] = [87, 87, 80, 85, 48, 102, 74, 89, 85, 89, 105, 112, 103, 106, 82, 114, 103, 47, 54, 105, 113, 88, 65, 55, 117, 73, 81, 54, 121, 90, 108, 102, 78, 97, 104, 74, 99, 104, 116, 67, 121, 47, 76, 68, 73, 110, 98, 89, 57, 69, 121, 78, 117, 102, 98, 105, 82, 116, 85, 84, 68, 65, 80, 100]
    
    internal init(endpoint: String = BuildConfiguration.googleAnalyticsMeasurementServiceURL) {
        self.endpoint = endpoint
    }
    
    internal func sendEvent(eventData: [String: Any]) {
        if var urlComponents = URLComponents(string: endpoint) {
            urlComponents.queryItems = [
                URLQueryItem(name: "measurement_id", value: Maze.shared.get(key: measurementID)),
                URLQueryItem(name: "api_secret", value: Maze.shared.get(key: measurementKey))
            ]
            
            if let url = urlComponents.url {
                if let body = try? JSONSerialization.data(withJSONObject: eventData, options: []) {
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    request.httpMethod = "POST"
                    
                    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in })
                    task.resume()
                }
            }
        }
    }
}
