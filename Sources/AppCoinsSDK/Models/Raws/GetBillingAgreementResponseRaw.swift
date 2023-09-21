//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

struct GetBillingAgreementResponseRaw: Codable {
    
    let uid: String
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case created = "created"
    }
    
}

struct GetBillingAgreementNotFoundResponseRaw: Codable {
    
    let code: String
    let path: String
    let text: String?
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
    
}
