//
//  AppCoinsSDKError.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

public enum AppCoinsSDKError: Error {
    
    case networkError(debugInfo: DebugInfo)
    case systemError(debugInfo: DebugInfo)
    case notEntitled(debugInfo: DebugInfo)
    case productUnavailable(debugInfo: DebugInfo)
    case purchaseNotAllowed(debugInfo: DebugInfo)
    case unknown(debugInfo: DebugInfo)
    
    // Convenience initializers for common error types
    public static func networkError(message: String, description: String) -> AppCoinsSDKError {
        return .networkError(debugInfo: DebugInfo(message: message, description: description))
    }
    
    public static func systemError(message: String, description: String) -> AppCoinsSDKError {
        return .systemError(debugInfo: DebugInfo(message: message, description: description))
    }
    
    public static func notEntitled(message: String, description: String) -> AppCoinsSDKError {
        return .notEntitled(debugInfo: DebugInfo(message: message, description: description))
    }
    
    public static func productUnavailable(message: String, description: String) -> AppCoinsSDKError {
        return .productUnavailable(debugInfo: DebugInfo(message: message, description: description))
    }
    
    public static func purchaseNotAllowed(message: String, description: String) -> AppCoinsSDKError {
        return .purchaseNotAllowed(debugInfo: DebugInfo(message: message, description: description))
    }
    
    public static func unknown(message: String, description: String) -> AppCoinsSDKError {
        return .unknown(debugInfo: DebugInfo(message: message, description: description))
    }
}

internal class DebugInfo {
    internal let message: String
    internal let description: String
    internal let request: DebugRequestInfo?
    
    public init(message: String, description: String, request: DebugRequestInfo? = nil) {
        self.message = message
        self.description = description
        self.request = request
    }
}

internal class DebugRequestInfo {
    internal let url: String
    internal let method: RequestMethod
    internal let body: String
    internal let responseData: String
    internal let statusCode: Int
    
    internal init(request: URLRequest, responseData: Data?, statusCode: Int) {
        // Extract URL as string, fallback to empty string if unavailable
        self.url = request.url?.absoluteString ?? "Unknown URL"
        
        // Map HTTP method to your RequestMethod enum or use a default
        if let httpMethod = request.httpMethod {
            self.method = RequestMethod(rawValue: httpMethod.uppercased()) ?? .unknown
        } else {
            self.method = .unknown
        }
        
        // Convert HTTP body to a string if available, fallback to empty string if not
        if let bodyData = request.httpBody {
            self.body = String(data: bodyData, encoding: .utf8) ?? "Unable to parse body"
        } else {
            self.body = "No body"
        }
        
        // Set the responseData as a string if available, otherwise an empty string
        if let data = responseData {
            self.responseData = String(data: data, encoding: .utf8) ?? "Unable to parse response data"
        } else {
            self.responseData = "No response data"
        }
        
        // Set the status code (passed as a parameter)
        self.statusCode = statusCode
    }
}
