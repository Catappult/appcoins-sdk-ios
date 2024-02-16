//
//  AptoideIOSService.swift
//
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal protocol AptoideIOSService {
    
    func isWalletAvailable(result: @escaping (Result<Bool, AptoideIOSServiceError>) -> Void)
    
}
