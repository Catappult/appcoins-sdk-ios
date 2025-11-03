//
//  OnPurchaseResultBody.swift
//  
//
//  Created by aptoide on 04/04/2025.
//

import Foundation

internal struct OnPurchaseResultBody: Codable {
    
    internal let responseCode: Int
    internal let purchaseData: PurchaseData
    internal let dataSignature: String
    internal let orderReference: String?
    internal let wallet: Wallet?
    
    internal enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case purchaseData = "purchase_data"
        case dataSignature = "data_signature"
        case orderReference = "order_reference"
        case wallet = "wallet"
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
            case orderId = "order_id"
            case packageName = "package_name"
            case productId = "product_id"
            case purchaseTime = "purchase_time"
            case purchaseToken = "purchase_token"
            case purchaseState = "purchase_state"
            case developerPayload = "developer_payload"
            case productType = "product_type"
            case isAutoRenewing = "is_auto_renewing"
        }
    }
    
    internal struct Wallet: Codable {
        internal let type: String
        internal let user: UserWalletBody?
        internal let guest: GuestWalletBody?

        internal enum CodingKeys: String, CodingKey {
            case type = "type"
            case user = "user"
            case guest = "guest"
        }
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "USER_WALLET":
                let userWallet = try container.decode(UserWalletBody.self, forKey: .user)
                user = userWallet
                guest = nil
            case "GUEST_WALLET":
                let guestWallet = try container.decode(GuestWalletBody.self, forKey: .guest)
                guest = guestWallet
                user = nil
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown wallet type: \(type)")
            }
        }
        
        internal func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            switch type {
            case "USER_WALLET":
                try container.encode(user, forKey: .user)
            case "GUEST_WALLET":
                try container.encode(guest, forKey: .guest)
            default:
                throw EncodingError.invalidValue("Unknown wallet type: \(type)", EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unknown wallet type: \(type)"))
            }
        }

        internal struct UserWalletBody: Codable {
            internal let address: String
            internal let authToken: String
            internal let refreshToken: String

            internal enum CodingKeys: String, CodingKey {
                case address = "address"
                case authToken = "auth_token"
                case refreshToken = "refresh_token"
            }
        }

        internal struct GuestWalletBody: Codable {
            internal let guestUID: String

            internal enum CodingKeys: String, CodingKey {
                case guestUID = "guest_uid"
            }
        }
    }
}
