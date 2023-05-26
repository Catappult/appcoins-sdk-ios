//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

struct AppCoinBalanceRaw : Codable {
    
    let wallet: String?
    let appcBalance: Double
    let ethUsdBalance: Double
    let appcUsdBalance: Double
    let appccUsdBalance: Double
    var appcNormalizedBalance: Double {
        return appcBalance / pow(10, 18)
    }
    var usdBalance: Double {
        return ethUsdBalance + appcUsdBalance + appccUsdBalance
    }
    
    enum CodingKeys: String, CodingKey {
        case wallet = "wallet"
        case appcBalance = "appc_c_balance"
        case ethUsdBalance = "eth_usd_balance"
        case appcUsdBalance = "appc_usd_balance"
        case appccUsdBalance = "appc_c_usd_balance"
    }
    
}
