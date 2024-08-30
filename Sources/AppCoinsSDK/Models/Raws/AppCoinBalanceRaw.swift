//
//  AppCoinBalanceRaw.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct AppCoinBalanceRaw: Codable {
    
    internal let wallet: String?
    internal let ethBalance: Double
    internal let appcBalance: Double
    internal let appcCBalance: Double
    internal var appcCNormalizedBalance: Double {
        return appcCBalance / pow(10, 18)
    }
    internal let currency: String
    internal let symbol: String
    internal let ethFiatBalance: Double
    internal let appcFiatBalance: Double
    internal let appcCFiatBalance: Double
    internal let blocked: Bool
    internal let blockLevel: BlockLevel
    internal let verified: Bool
    internal let verificationMethod: String?
    internal let logging: Bool
    internal let hasBackup: Bool
    internal let lastBackupDate: String?
    internal let sentryBreadCrumbs: Int
    internal let intercomActive: Bool
    
    internal enum CodingKeys: String, CodingKey {
        case wallet = "wallet"
        case ethBalance = "eth_balance"
        case appcBalance = "appc_balance"
        case appcCBalance = "appc_c_balance"
        case currency = "currency"
        case symbol = "symbol"
        case ethFiatBalance = "eth_fiat_balance"
        case appcFiatBalance = "appc_fiat_balance"
        case appcCFiatBalance = "appc_c_fiat_balance"
        case blocked = "blocked"
        case blockLevel = "block_level"
        case verified = "verified"
        case verificationMethod = "verification_method"
        case logging = "logging"
        case hasBackup = "has_backup"
        case lastBackupDate = "last_backup_date"
        case sentryBreadCrumbs = "sentry_breadcrumbs"
        case intercomActive = "intercom_active"
    }
    
    internal struct BlockLevel: Codable {
        internal let level: Int
        internal let name: String
        
        internal enum CodingKeys: String, CodingKey {
            case level = "level"
            case name = "name"
        }
    }
    
}
