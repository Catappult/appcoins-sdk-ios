//
//  File.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

public struct CreateBillingAgreementTokenRaw: Codable {
    
    let urls: CreateBillingAgreementTokenURLsRaw
    
    enum CodingKeys: String, CodingKey {
        case urls = "urls"
    }
    
    init(urls: CreateBillingAgreementTokenURLsRaw) {
        self.urls = urls
    }
    
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

public struct CreateBillingAgreementTokenURLsRaw: Codable {
    
    let returnURL: String
    let cancelURL: String
    
    enum CodingKeys: String, CodingKey {
        case returnURL = "return"
        case cancelURL = "cancel"
    }
    
    init(returnURL: String, cancelURL: String) {
        self.returnURL = returnURL
        self.cancelURL = cancelURL
    }
    
    func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

public struct CreateBillingAgreementTokenResponseRaw: Codable {
    
    let token: String
    let redirect: CreateBillingAgreementTokenResponseRedirectRaw
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case redirect = "redirect"
    }
}

public struct CreateBillingAgreementTokenResponseRedirectRaw: Codable {
    
    let url: String
    let method: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case method = "method"
    }
}

