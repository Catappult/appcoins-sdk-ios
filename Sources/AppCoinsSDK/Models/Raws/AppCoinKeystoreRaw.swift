//
//  File.swift
//  
//
//  Created by aptoide on 16/05/2023.
//

import Foundation

struct AppCoinKeystoreRaw: Decodable, Encodable {
    
    let crypto: CryptoParamsV3
    let id: String?
    let version: Int
    let isHDWallet: Bool
    let address: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        crypto = try values.decodeIfPresent(CryptoParamsV3.self, forKey: .crypto)!
        id = try values.decodeIfPresent(String.self, forKey: .id)
        version = try values.decodeIfPresent(Int.self, forKey: .version)!
        address = try values.decodeIfPresent(String.self, forKey: .address)
        isHDWallet = try values.decodeIfPresent(Bool.self, forKey: .isHDWallet) ?? false
    }
    
    func toJSON() -> Data! {
        return try! JSONEncoder().encode(self)
    }

}

struct KdfParamsV3: Decodable, Encodable {
    let salt: String
    let dklen: Int
    let n: Int?
    let p: Int?
    let r: Int?
    let c: Int?
    let prf: String?
}

struct CipherParamsV3: Decodable, Encodable {
    let iv: String
}

struct CryptoParamsV3: Decodable, Encodable {
    let ciphertext: String
    let cipher: String
    let cipherparams: CipherParamsV3
    let kdf: String
    let kdfparams: KdfParamsV3
    let mac: String
    let version: String?
}
