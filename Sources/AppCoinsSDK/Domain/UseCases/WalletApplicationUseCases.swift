//
//  WalletApplicationUseCases.swift
//  
//
//  Created by aptoide on 16/02/2024.
//

import SwiftUI

internal class WalletApplicationUseCases {
    
    static var shared : WalletApplicationUseCases = WalletApplicationUseCases()
    
    private var repository: WalletApplicationRepositoryProtocol
    
    private init(repository: WalletApplicationRepositoryProtocol = WalletApplicationRepository()) {
        self.repository = repository
    }
    
    internal func isWalletInstalled() -> Bool {
        return UIApplication.shared.canOpenURL((URL(string: "com.aptoide.appcoins-wallet://"))!)
    }
    
    internal func isWalletAvailable() -> Bool {
        return false
    }
    
}
