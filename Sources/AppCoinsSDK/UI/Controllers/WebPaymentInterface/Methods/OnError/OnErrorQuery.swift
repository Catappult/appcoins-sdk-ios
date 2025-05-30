//
//  OnErrorQuery.swift
//
//
//  Created by aptoide on 08/05/2025.
//

import Foundation

internal struct OnErrorQuery {
    
    internal let checkoutError: String
    internal let message: String
    internal let description: String
    internal let request: RequestError?
    
    internal enum CodingKeys: String, CodingKey {
        case checkoutError = "checkoutError"
        case message = "message"
        case description = "description"
        case request = "request"
    }
    
    internal struct RequestError: Codable {
        
        internal let url: String
        internal let method: String
        internal let body: String
        internal let responseData: String
        internal let statusCode: Int
        
        internal enum CodingKeys: String, CodingKey {
            case url = "url"
            case method = "method"
            case body = "body"
            case responseData = "responseData"
            case statusCode = "statusCode"
        }
        
        init(url: String?, method: String?, body: String?, responseData: String?, statusCode: String?) throws {
            
            guard let url = url else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field request.url is missing or incorrect at OnErrorQuery.swift:init") }
            guard let method = method else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field request.method is missing or incorrect at OnErrorQuery.swift:init") }
            guard let body = body else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field request.body is missing or incorrect at OnErrorQuery.swift:init") }
            guard let responseData = responseData else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field request.response_data is missing or incorrect at OnErrorQuery.swift:init") }
            guard let statusCode = statusCode.flatMap({ Int($0) }) else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field request.status_code is missing or incorrect at OnErrorQuery.swift:init") }
            
            self.url = url
            self.method = method
            self.body = body
            self.responseData = responseData
            self.statusCode = statusCode
        }
    }
    
    init(deeplink: URL) throws {
        let components = URLComponents(url: deeplink, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        // Helper to fetch raw string or nil
        func string(for key: String) -> String? {
            return queryItems.first(where: { $0.name == key })?.value
        }
        
        guard let checkoutError = string(for: "checkout_error") else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field checkout_error is missing or incorrect at OnErrorQuery.swift:init") }
        guard let message = string(for: "message") else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field message is missing or incorrect at OnErrorQuery.swift:init") }
        guard let description = string(for: "description") else { throw AppCoinsSDKError.systemError(message: "Failed to process OnError deeplink", description: "Field description is missing or incorrect at OnErrorQuery.swift:init") }
        
        var request: OnErrorQuery.RequestError?
        if let requestURL = string(for: "request.url") {
            request = try RequestError(
                url: string(for: "request.url"),
                method: string(for: "request.method"),
                body: string(for: "request.body"),
                responseData: string(for: "request.response_data"),
                statusCode: string(for: "request.status_code")
            )
        } else {
            request = nil
        }
        
        self.checkoutError = checkoutError
        self.message = message
        self.description = description
        self.request = request
    }
}
