//
//  AttributionClient.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation
@_implementationOnly import DeviceKit
import UIKit

internal class MMPClient: MMPService {

    private let endpoint: String

    // Exponential backoff configuration for the attribution request.
    // The request is retried until a 200 response is received, with the delay
    // doubling after each attempt up to a maximum cap.
    private let initialBackoff: TimeInterval = 1
    private let maxBackoff: TimeInterval = 60
    private let backoffMultiplier: Double = 2

    internal init(endpoint: String = BuildConfiguration.mmpServiceBaseURL) {
        self.endpoint = endpoint
    }

    internal func getAttribution(bundleID: String, result: @escaping (Result<AttributionRaw, Error>) -> Void) {
        self.requestAttribution(bundleID: bundleID, backoff: self.initialBackoff, result: result)
    }

    private func requestAttribution(bundleID: String, backoff: TimeInterval, result: @escaping (Result<AttributionRaw, Error>) -> Void) {

        if let requestURL = URL(string: "\(endpoint)/api/v1/attribution?package_name=\(bundleID)") {
            var request = URLRequest(url: requestURL)

            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10

            let userAgent = self.getMMPUserAgent()
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                let statusCode = (response as? HTTPURLResponse)?.statusCode

                if statusCode == 200, let data = data, let findResult = try? JSONDecoder().decode(AttributionRaw.self, from: data) {
                    Utils.log("Attribution request succeeded with status 200.", category: "MMP")
                    result(.success(findResult))
                } else {
                    // Any non-200 response, network error or decoding failure triggers a
                    // retry with exponential backoff until a 200 is eventually received.
                    let statusDescription = statusCode.map { "status \($0)" } ?? (error.map { "error: \($0.localizedDescription)" } ?? "unknown failure")
                    Utils.log("Attribution request failed (\(statusDescription)). Retrying in \(backoff)s.", category: "MMP", level: .error)
                    self.retryAttribution(bundleID: bundleID, backoff: backoff, result: result)
                }
            }
            task.resume()
        }
    }

    private func retryAttribution(bundleID: String, backoff: TimeInterval, result: @escaping (Result<AttributionRaw, Error>) -> Void) {
        let nextBackoff = min(backoff * self.backoffMultiplier, self.maxBackoff)
        DispatchQueue.global().asyncAfter(deadline: .now() + backoff) {
            self.requestAttribution(bundleID: bundleID, backoff: nextBackoff, result: result)
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
