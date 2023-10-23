//
//  CreateBillingAgreementResponseRaw.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal struct CreateBillingAgreementResponseRaw: Codable {
    
    internal let uid: String
    
    internal enum CodingKeys: String, CodingKey {
        case uid = "uid"
    }
}
