//
//  APPCService.swift
//
//
//  Created by aptoide on 12/07/2024.
//

import Foundation

internal protocol APPCService {
    
    func getGuestWallet(guestUID: String, result: @escaping (Result<GuestWalletRaw, APPCServiceError>) -> Void)
    func refreshUserWallet(refreshToken: String, result: @escaping (Result<GuestWalletRaw, APPCServiceError>) -> Void)
    
}
