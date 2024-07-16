//
//  WalletApplicationRepository.swift
//  
//
//  Created by aptoide on 16/02/2024.
//

import Foundation

internal class WalletApplicationRepository: WalletApplicationRepositoryProtocol {
    
    private let iosService: AptoideIOSService = AptoideIOSServiceClient()
    
    internal func isWalletAvailable(completion: @escaping (Bool) -> Void) {
        iosService.isWalletAvailable() {
            result in
            
            switch result {
            case .success(let response):
                completion(response)
            case .failure(let failure):
                completion(false)
            }
        }
    }

}
