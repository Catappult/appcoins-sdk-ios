//
//  AttributionClient.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation
import DeviceKit
import UIKit

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
            
            let userAgent = self.getMMPUserAgent()
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
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
    
    internal func getMMPUserAgent() -> String {
        let appName = "iOSAppCoinsSDK"
        let appVersion = BuildConfiguration.sdkShortVersion
        let deviceName = Device.current.description
        let systemVersion = Device.current.systemVersion?.description ?? "Unknown iOS version"
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "Unknown Bundle ID"
        
        // Device ID
        let UID = UIDevice.current.identifierForVendor!.uuidString
        
        // missing
        let apiLevel = ProcessInfo().operatingSystemVersion.majorVersion
        let cpu = "arm64" // standard value for most recent devices, no apple framework to retrieve this information
        let vercode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let md5 = Utils.md5("iOSAppCoinsSDK")
        let resolution = "0x0"
        
        return "\(appName)/\(appVersion) (iPhone; iOS \(systemVersion); \(apiLevel); \(deviceName); \(cpu); \(bundleIdentifier); \(vercode); \(md5); \(resolution); \(UID))"
    }
}
