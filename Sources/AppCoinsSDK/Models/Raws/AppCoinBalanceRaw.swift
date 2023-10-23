//
//  AppCoinBalanceRaw.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct AppCoinBalanceRaw : Codable {
    
    internal let wallet: String?
    internal let appcBalance: Double
    internal let ethUsdBalance: Double
    internal let appcUsdBalance: Double
    internal let appccUsdBalance: Double
    internal var appcNormalizedBalance: Double {
        return appcBalance / pow(10, 18)
    }
    internal var usdBalance: Double {
        return ethUsdBalance + appcUsdBalance + appccUsdBalance
    }
    
    internal enum CodingKeys: String, CodingKey {
        case wallet = "wallet"
        case appcBalance = "appc_c_balance"
        case ethUsdBalance = "eth_usd_balance"
        case appcUsdBalance = "appc_usd_balance"
        case appccUsdBalance = "appc_c_usd_balance"
    }
    
}
