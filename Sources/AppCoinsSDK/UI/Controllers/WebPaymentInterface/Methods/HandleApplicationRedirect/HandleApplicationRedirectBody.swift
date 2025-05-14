//
//  HandleApplicationRedirectBody.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 06/05/2025.
//

import Foundation

internal struct HandleApplicationRedirectBody: Codable {
    
    internal let URL: String
    
    internal enum CodingKeys: String, CodingKey {
        case URL = "URL"
    }
}
