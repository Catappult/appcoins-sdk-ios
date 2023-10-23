//
//  AppCoinKeystoreRaw.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

internal struct AppCoinKeystoreRaw: Decodable, Encodable {
    
    internal let crypto: CryptoParamsV3
    internal let id: String?
    internal let version: Int
    internal let isHDWallet: Bool
    internal let address: String?
    
    internal init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        crypto = try values.decodeIfPresent(CryptoParamsV3.self, forKey: .crypto)!
        id = try values.decodeIfPresent(String.self, forKey: .id)
        version = try values.decodeIfPresent(Int.self, forKey: .version)!
        address = try values.decodeIfPresent(String.self, forKey: .address)
        isHDWallet = try values.decodeIfPresent(Bool.self, forKey: .isHDWallet) ?? false
    }
    
    internal func toJSON() -> Data! {
        return try! JSONEncoder().encode(self)
    }

}

internal struct KdfParamsV3: Decodable, Encodable {
    internal let salt: String
    internal let dklen: Int
    internal let n: Int?
    internal let p: Int?
    internal let r: Int?
    internal let c: Int?
    internal let prf: String?
}

internal struct CipherParamsV3: Decodable, Encodable {
    internal let iv: String
}

internal struct CryptoParamsV3: Decodable, Encodable {
    internal let ciphertext: String
    internal let cipher: String
    internal let cipherparams: CipherParamsV3
    internal let kdf: String
    internal let kdfparams: KdfParamsV3
    internal let mac: String
    internal let version: String?
}
