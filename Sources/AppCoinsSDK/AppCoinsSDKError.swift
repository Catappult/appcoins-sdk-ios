//
//  AppCoinsSDKError.swift
//  
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

public enum AppCoinsSDKError: Error, CustomStringConvertible {
    
    case networkError(debugInfo: DebugInfo)
    case systemError(debugInfo: DebugInfo)
    case notEntitled(debugInfo: DebugInfo)
    case productUnavailable(debugInfo: DebugInfo)
    case purchaseNotAllowed(debugInfo: DebugInfo)
    case unknown(debugInfo: DebugInfo)
    
    internal static func fromWebCheckoutError(webCheckoutError: OnErrorBody) -> AppCoinsSDKError {
        switch webCheckoutError.checkoutError {
        case "failed":
            return .systemError(
                message: webCheckoutError.message,
                description: webCheckoutError.description,
                request: DebugRequestInfo.fromWebCheckoutErrorRequest(webCheckoutErrorRequest: webCheckoutError.request)
            )
        case "network":
            return .networkError(
                message: webCheckoutError.message,
                description: webCheckoutError.description,
                request: DebugRequestInfo.fromWebCheckoutErrorRequest(webCheckoutErrorRequest: webCheckoutError.request)
            )
        default:
            return .unknown(
                message: webCheckoutError.message,
                description: webCheckoutError.description,
                request: DebugRequestInfo.fromWebCheckoutErrorRequest(webCheckoutErrorRequest: webCheckoutError.request)
            )
        }
    }
    
    // Convenience initializers for common error types
    internal static func networkError(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        return .networkError(debugInfo: DebugInfo(message: message, description: description, request: request))
    }
    
    internal static func systemError(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        return .systemError(debugInfo: DebugInfo(message: message, description: description, request: request))
    }
    
    internal static func notEntitled(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        return .notEntitled(debugInfo: DebugInfo(message: message, description: description, request: request))
    }
    
    internal static func productUnavailable(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        return .productUnavailable(debugInfo: DebugInfo(message: message, description: description, request: request))
    }
    
    internal static func purchaseNotAllowed(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        return .purchaseNotAllowed(debugInfo: DebugInfo(message: message, description: description, request: request))
    }
    
    internal static func unknown(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        return .unknown(debugInfo: DebugInfo(message: message, description: description, request: request))
    }
    
    public var description: String {
        switch self {
        case .networkError(let debugInfo):
            if let debugRequestInfo = debugInfo.request {
                return """
                    {
                        "type": "networkError",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": {
                            "url": "\(debugRequestInfo.url)",
                            "method": "\(debugRequestInfo.method)",
                            "body": "\(debugRequestInfo.body)",
                            "responseData": \(debugRequestInfo.responseData),
                            "statusCode": \(debugRequestInfo.statusCode)
                        }
                    }
                    """
            } else {
                return """
                    {
                        "type": "networkError",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": null
                    }
                    """
            }
        case .systemError(let debugInfo):
            if let debugRequestInfo = debugInfo.request {
                return """
                    {
                        "type": "systemError",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": {
                            "url": "\(debugRequestInfo.url)",
                            "method": "\(debugRequestInfo.method)",
                            "body": "\(debugRequestInfo.body)",
                            "responseData": \(debugRequestInfo.responseData),
                            "statusCode": \(debugRequestInfo.statusCode)
                        }
                    }
                    """
            } else {
                return """
                    {
                        "type": "systemError",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": null
                    }
                    """
            }
        case .notEntitled(let debugInfo):
            if let debugRequestInfo = debugInfo.request {
                return """
                    {
                        "type": "notEntitled",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": {
                            "url": "\(debugRequestInfo.url)",
                            "method": "\(debugRequestInfo.method)",
                            "body": "\(debugRequestInfo.body)",
                            "responseData": \(debugRequestInfo.responseData),
                            "statusCode": \(debugRequestInfo.statusCode)
                        }
                    }
                    """
            } else {
                return """
                    {
                        "type": "notEntitled",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": null
                    }
                    """
            }
        case .productUnavailable(let debugInfo):
            if let debugRequestInfo = debugInfo.request {
                return """
                    {
                        "type": "productUnavailable",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": {
                            "url": "\(debugRequestInfo.url)",
                            "method": "\(debugRequestInfo.method)",
                            "body": "\(debugRequestInfo.body)",
                            "responseData": \(debugRequestInfo.responseData),
                            "statusCode": \(debugRequestInfo.statusCode)
                        }
                    }
                    """
            } else {
                return """
                    {
                        "type": "productUnavailable",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": null
                    }
                    """
            }
        case .purchaseNotAllowed(let debugInfo):
            if let debugRequestInfo = debugInfo.request {
                return """
                    {
                        "type": "purchaseNotAllowed",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": {
                            "url": "\(debugRequestInfo.url)",
                            "method": "\(debugRequestInfo.method)",
                            "body": "\(debugRequestInfo.body)",
                            "responseData": \(debugRequestInfo.responseData),
                            "statusCode": \(debugRequestInfo.statusCode)
                        }
                    }
                    """
            } else {
                return """
                    {
                        "type": "purchaseNotAllowed",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": null
                    }
                    """
            }
        case .unknown(let debugInfo):
            if let debugRequestInfo = debugInfo.request {
                return """
                    {
                        "type": "unknown",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": {
                            "url": "\(debugRequestInfo.url)",
                            "method": "\(debugRequestInfo.method)",
                            "body": "\(debugRequestInfo.body)",
                            "responseData": \(debugRequestInfo.responseData),
                            "statusCode": \(debugRequestInfo.statusCode)
                        }
                    }
                    """
            } else {
                return """
                    {
                        "type": "unknown",
                        "message": "\(debugInfo.message)",
                        "description": "\(debugInfo.description)",
                        "request": null
                    }
                    """
            }
        }
    }
}

public class DebugInfo {
    public let message: String
    public let description: String
    public let request: DebugRequestInfo?
    
    internal init(message: String, description: String, request: DebugRequestInfo? = nil) {
        self.message = message
        self.description = description
        self.request = request
    }
}

public class DebugRequestInfo {
    public let url: String
    public let method: RequestMethod
    public let body: String
    public let responseData: String
    public let statusCode: Int

    internal init(request: URLRequest, responseData: Data?, response: URLResponse?) {
        // Extract URL as string, fallback to empty string if unavailable
        self.url = request.url?.absoluteString ?? "Unknown URL"
        
        // Map HTTP method to your RequestMethod enum or use a default
        if let httpMethod = request.httpMethod {
            self.method = RequestMethod(rawValue: httpMethod.uppercased()) ?? .UNKNOWN
        } else {
            self.method = .UNKNOWN
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
        
        // Set the status code from the response, defaulting to 0 if the response is nil or not an HTTPURLResponse
        if let httpResponse = response as? HTTPURLResponse {
            self.statusCode = httpResponse.statusCode
        } else {
            self.statusCode = 0 // or handle it differently if desired
        }
    }
    
    internal init(url: String, method: RequestMethod, body: String, responseData: String, statusCode: Int) {
        self.url = url
        self.method = method
        self.body = body
        self.responseData = responseData
        self.statusCode = statusCode
    }
    
    internal static func fromWebCheckoutErrorRequest(webCheckoutErrorRequest: OnErrorBody.RequestError) -> DebugRequestInfo {
        return DebugRequestInfo(
            url: webCheckoutErrorRequest.url,
            method: RequestMethod(method: webCheckoutErrorRequest.method),
            body: webCheckoutErrorRequest.body,
            responseData: webCheckoutErrorRequest.responseData,
            statusCode: webCheckoutErrorRequest.statusCode
        )
    }
}
