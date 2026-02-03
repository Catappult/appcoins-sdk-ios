//
//  ExternalPurchaseToken.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

internal struct ExternalPurchaseToken: Decodable, CustomStringConvertible {
    let appAppleId: Int
    let bundleId: String
    let tokenCreationDate: Int64
    let externalPurchaseId: String
    let tokenType: String
    
    var description: String {
        """
        ExternalPurchaseToken(
            appAppleId: \(appAppleId),
            bundleId: \(bundleId),
            tokenCreationDate: \(tokenCreationDate),
            externalPurchaseId: \(externalPurchaseId),
            tokenType: \(tokenType)
        )
        """
    }
}
