//
//  WalletApplicationRepositoryProtocol.swift
//  
//
//  Created by aptoide on 16/02/2024.
//

import Foundation

internal protocol WalletApplicationRepositoryProtocol {
    
    func isWalletAvailable(completion: @escaping (Bool) -> Void)
    
}
