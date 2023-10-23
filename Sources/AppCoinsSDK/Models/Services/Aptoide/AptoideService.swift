//
//  AptoideService.swift
//  
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal protocol AptoideService {
    
    func getDeveloperWalletAddressByPackageName(package: String, result: @escaping (Result<FindDeveloperWalletAddressRaw, AptoideServiceError>) -> Void)
    
}
