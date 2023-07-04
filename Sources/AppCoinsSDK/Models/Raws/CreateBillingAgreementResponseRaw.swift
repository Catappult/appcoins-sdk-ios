//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

public struct CreateBillingAgreementResponseRaw: Codable {
    
    let uid: String
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
    }
}
