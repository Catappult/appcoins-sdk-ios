//
//  GetBillingAgreementResponseRaw.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal struct GetBillingAgreementResponseRaw: Codable {
    
    internal let uid: String
    internal let created: String
    
    internal enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case created = "created"
    }
    
}

internal struct GetBillingAgreementNotFoundResponseRaw: Codable {
    
    internal let code: String
    internal let path: String
    internal let text: String?
    internal let data: String?
    
    internal enum CodingKeys: String, CodingKey {
        case code = "code"
        case path = "path"
        case text = "text"
        case data = "data"
    }
    
}
