//
//  AppCoinsSDKError.swift
//
//
//  Created by aptoide on 22/05/2023.
//

import Foundation

public enum AppCoinsSDKError: Error, CustomStringConvertible {

    case networkError(_ description: String = "")
    case systemError(_ description: String = "")
    case notEntitled(_ description: String = "")
    case productUnavailable(_ description: String = "")
    case purchaseNotAllowed(_ description: String = "")
    case unknown(_ description: String = "")

    public var description: String {
        switch self {
        case .networkError(let d): return d
        case .systemError(let d): return d
        case .notEntitled(let d): return d
        case .productUnavailable(let d): return d
        case .purchaseNotAllowed(let d): return d
        case .unknown(let d): return d
        }
    }
}

// MARK: - Internal construction helpers

internal extension AppCoinsSDKError {

    static func fromWebCheckoutError(body: OnErrorBody) -> AppCoinsSDKError {
        let req = body.request.flatMap { DebugRequestInfo.fromWebCheckoutError(body: $0) }
        switch body.checkoutError {
        case "failed":  return .systemError(message: body.message, description: body.description, request: req)
        case "network": return .networkError(message: body.message, description: body.description, request: req)
        default:        return .unknown(message: body.message, description: body.description, request: req)
        }
    }

    static func fromWebCheckoutError(query: OnErrorQuery) -> AppCoinsSDKError {
        let req = query.request.flatMap { DebugRequestInfo.fromWebCheckoutError(query: $0) }
        switch query.checkoutError {
        case "failed":  return .systemError(message: query.message, description: query.description, request: req)
        case "network": return .networkError(message: query.message, description: query.description, request: req)
        default:        return .unknown(message: query.message, description: query.description, request: req)
        }
    }

    static func networkError(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        .networkError(DebugInfo(message: message, description: description, request: request).format())
    }

    static func systemError(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        .systemError(DebugInfo(message: message, description: description, request: request).format())
    }

    static func notEntitled(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        .notEntitled(DebugInfo(message: message, description: description, request: request).format())
    }

    static func productUnavailable(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        .productUnavailable(DebugInfo(message: message, description: description, request: request).format())
    }

    static func purchaseNotAllowed(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        .purchaseNotAllowed(DebugInfo(message: message, description: description, request: request).format())
    }

    static func unknown(message: String, description: String, request: DebugRequestInfo? = nil) -> AppCoinsSDKError {
        .unknown(DebugInfo(message: message, description: description, request: request).format())
    }
}

// MARK: - Internal debug types

internal class DebugInfo {
    let message: String
    let description: String
    let request: DebugRequestInfo?

    init(message: String, description: String, request: DebugRequestInfo? = nil) {
        self.message = message
        self.description = description
        self.request = request
    }

    func format() -> String {
        if let req = request {
            return """
                {
                    "message": "\(message)",
                    "description": "\(description)",
                    "request": {
                        "url": "\(req.url)",
                        "method": "\(req.method)",
                        "body": "\(req.body)",
                        "responseData": \(req.responseData),
                        "statusCode": \(req.statusCode)
                    }
                }
                """
        } else {
            return """
                {
                    "message": "\(message)",
                    "description": "\(description)",
                    "request": null
                }
                """
        }
    }
}

internal class DebugRequestInfo {
    let url: String
    let method: String
    let body: String
    let responseData: String
    let statusCode: Int

    init(request: URLRequest, responseData: Data?, response: URLResponse?) {
        self.url = request.url?.absoluteString ?? "Unknown URL"
        self.method = request.httpMethod?.uppercased() ?? "UNKNOWN"

        if let bodyData = request.httpBody {
            self.body = String(data: bodyData, encoding: .utf8) ?? "Unable to parse body"
        } else {
            self.body = "No body"
        }

        if let data = responseData {
            self.responseData = "\"" + (String(data: data, encoding: .utf8) ?? "Unable to parse response data") + "\""
        } else {
            self.responseData = "null"
        }

        if let httpResponse = response as? HTTPURLResponse {
            self.statusCode = httpResponse.statusCode
        } else {
            self.statusCode = 0
        }
    }

    init(url: String, method: String, body: String, responseData: String, statusCode: Int) {
        self.url = url
        self.method = method
        self.body = body
        self.responseData = responseData
        self.statusCode = statusCode
    }

    static func fromWebCheckoutError(body: OnErrorBody.RequestError) -> DebugRequestInfo {
        return DebugRequestInfo(url: body.url, method: body.method, body: body.body, responseData: body.responseData, statusCode: body.statusCode)
    }

    static func fromWebCheckoutError(query: OnErrorQuery.RequestError) -> DebugRequestInfo {
        return DebugRequestInfo(url: query.url, method: query.method, body: query.body, responseData: query.responseData, statusCode: query.statusCode)
    }
}
