//
//  FindDeveloperWalletAddresRaw.swift
//  
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal struct FindDeveloperWalletAddressRaw : Codable {
    
    internal let data: FindDeveloperWalletAddressDataRaw
    
    internal enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

internal struct FindDeveloperWalletAddressDataRaw : Codable {
    
    internal let address: String
    
    internal enum CodingKeys: String, CodingKey {
        case address = "address"
    }
    
}
