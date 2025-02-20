//
//  RequestMethod.swift
//  
//
//  Created by aptoide on 02/10/2024.
//

import Foundation

public enum RequestMethod: String {
    case GET = "GET"
    case POST = "POST"
    case UNKNOWN = "UNKNOWN"
    
    internal init(method: String) {
        switch method {
        case "GET":
            self = .GET
        case "POST":
            self = .POST
        default:
            self = .UNKNOWN
        }
    }
}
