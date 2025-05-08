//
//  OnPurchaseResultQuery.swift
//
//
//  Created by aptoide on 08/05/2025.
//

import Foundation

internal struct OnPurchaseResultQuery {
    
    internal let responseCode: Int
    internal let purchaseData: PurchaseData
    internal let dataSignature: String
    internal let orderReference: String?
    internal let wallet: Wallet?
    
    internal enum CodingKeys: String, CodingKey {
        case responseCode = "responseCode"
        case purchaseData = "purchaseData"
        case dataSignature = "dataSignature"
        case orderReference = "orderReference"
    }
    
    internal struct PurchaseData: Codable {
        
        internal let orderId: String
        internal let packageName: String
        internal let productId: String
        internal let purchaseTime: Int
        internal let purchaseToken: String
        internal let purchaseState: Int
        internal let developerPayload: String
        internal let productType: String
        internal let isAutoRenewing: Bool
        
        internal enum CodingKeys: String, CodingKey {
            case orderId = "orderId"
            case packageName = "packageName"
            case productId = "productId"
            case purchaseTime = "purchaseTime"
            case purchaseToken = "purchaseToken"
            case purchaseState = "purchaseState"
            case developerPayload = "developerPayload"
            case productType = "productType"
            case isAutoRenewing = "isAutoRenewing"
        }
        
        init(orderId: String?, packageName: String?, productId: String?, purchaseTime: String?, purchaseToken: String?, purchaseState: String?, developerPayload: String?, productType: String?, isAutoRenewing: String?) throws {
            
            guard let orderId = orderId else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.order_id is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let packageName = packageName else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.package_name is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let productId = productId else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.product_id is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let purchaseTime = purchaseTime.flatMap({ Int($0) }) else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.purchase_time is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let purchaseToken = purchaseToken else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.purchase_token is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let purchaseState = purchaseState.flatMap({ Int($0) }) else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.purchase_state is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let developerPayload = developerPayload else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.developer_payload is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let productType = productType else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.product_type is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            guard let isAutoRenewing = isAutoRenewing.flatMap({ $0.uppercased() == "TRUE" }) else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field purchase_data.is_auto_renewing is missing or incorrect at OnPurchaseResultQuery.swift:init") }
            
            self.orderId = orderId
            self.packageName = packageName
            self.productId = productId
            self.purchaseTime = purchaseTime
            self.purchaseToken = purchaseToken
            self.purchaseState = purchaseState
            self.developerPayload = developerPayload
            self.productType = productType
            self.isAutoRenewing = isAutoRenewing
        }
    }
    
    internal enum Wallet {
        case user(User)
        case guest(Guest)

        internal struct User {
            internal let address: String
            internal let authToken: String
            internal let refreshToken: String
            
            init(address: String?, authToken: String?, refreshToken: String?) throws {
                guard let address = address else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field wallet.user.address is missing or incorrect at OnPurchaseResultQuery.swift:init") }
                guard let authToken = authToken else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field wallet.user.auth_token is missing or incorrect at OnPurchaseResultQuery.swift:init") }
                guard let refreshToken = refreshToken else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field wallet.user.refresh_token is missing or incorrect at OnPurchaseResultQuery.swift:init") }
                
                self.address = address
                self.authToken = authToken
                self.refreshToken = refreshToken
            }
        }

        internal struct Guest {
            internal let guestUID: String
            
            init(guestUID: String?) throws {
                guard let guestUID = guestUID else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field wallet.guest.guest_uid is missing or incorrect at OnPurchaseResultQuery.swift:init") }
                
                self.guestUID = guestUID
            }
        }
    }
    
    init(deeplink: URL) throws {
        let components = URLComponents(url: deeplink, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        // Helper to fetch raw string or nil
        func string(for key: String) -> String? {
            return queryItems.first(where: { $0.name == key })?.value
        }
        
        guard let responseCode = string(for: "response_code").flatMap({ Int($0) }) else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field response_code is missing or incorrect at OnPurchaseResultQuery.swift:init") }
        guard let dataSignature = string(for: "data_signature") else { throw AppCoinsSDKError.systemError(message: "Failed to process OnPurchaseResult deeplink", description: "Field data_signature is missing or incorrect at OnPurchaseResultQuery.swift:init") }

        let purchaseData = try OnPurchaseResultQuery.PurchaseData(
            orderId: string(for: "purchase_data[order_id]"),
            packageName: string(for: "purchase_data[package_name]"),
            productId: string(for: "purchase_data[product_id]"),
            purchaseTime: string(for: "purchase_data[purchase_time]"),
            purchaseToken: string(for: "purchase_data[purchase_token]"),
            purchaseState: string(for: "purchase_data[purchase_state]"),
            developerPayload: string(for: "purchase_data[developer_payload]"),
            productType: string(for: "purchase_data[product_type]"),
            isAutoRenewing: string(for: "purchase_data[is_auto_renewing]")
        )
        
        var wallet: OnPurchaseResultQuery.Wallet?
        if let walletType = string(for: "wallet[type]") {
            switch walletType.uppercased() {
            case "USER":
                let user = try OnPurchaseResultQuery.Wallet.User(
                    address: string(for: "wallet[user][address]"),
                    authToken: string(for: "wallet[user][auth_token]"),
                    refreshToken: string(for: "wallet[user][refresh_token]")
                )
                wallet = .user(user)
            case "GUEST":
                let guest = try OnPurchaseResultQuery.Wallet.Guest(
                    guestUID: string(for: "wallet[guest][guest_uid]")
                )
                wallet = .guest(guest)
            default:
                wallet = nil
            }
        } else {
            wallet = nil
        }
        
        self.responseCode = responseCode
        self.purchaseData = purchaseData
        self.dataSignature = dataSignature
        self.orderReference = string(for: "order_reference")
        self.wallet = wallet
    }
}
