//
//  OnErrorBody.swift
//  
//
//  Created by aptoide on 04/04/2025.
//

import Foundation

internal struct OnErrorBody: Codable {
    
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
    }
    
}
