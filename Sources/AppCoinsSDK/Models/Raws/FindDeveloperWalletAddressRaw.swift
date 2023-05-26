//
//  File.swift
//  
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

struct FindDeveloperWalletAddressRaw : Codable {
    
    let data: FindDeveloperWalletAddressDataRaw
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct FindDeveloperWalletAddressDataRaw : Codable {
    
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
    }
    
}
