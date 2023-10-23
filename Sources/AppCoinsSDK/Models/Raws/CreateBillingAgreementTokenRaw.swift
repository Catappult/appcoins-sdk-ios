//
//  CreateBillingAgreementTokenRaw.swift
//  
//
//  Created by aptoide on 20/06/2023.
//

import Foundation

internal struct CreateBillingAgreementTokenRaw: Codable {
    
    internal let urls: CreateBillingAgreementTokenURLsRaw
    
    internal enum CodingKeys: String, CodingKey {
        case urls = "urls"
    }
    
    internal init(urls: CreateBillingAgreementTokenURLsRaw) {
        self.urls = urls
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

internal struct CreateBillingAgreementTokenURLsRaw: Codable {
    
    internal let returnURL: String
    internal let cancelURL: String
    
    internal enum CodingKeys: String, CodingKey {
        case returnURL = "return"
        case cancelURL = "cancel"
    }
    
    internal init(returnURL: String, cancelURL: String) {
        self.returnURL = returnURL
        self.cancelURL = cancelURL
    }
    
    internal func toJSON() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

internal struct CreateBillingAgreementTokenResponseRaw: Codable {
    
    internal let token: String
    internal let redirect: CreateBillingAgreementTokenResponseRedirectRaw
    
    internal enum CodingKeys: String, CodingKey {
        case token = "token"
        case redirect = "redirect"
    }
}

internal struct CreateBillingAgreementTokenResponseRedirectRaw: Codable {
    
    internal let url: String
    internal let method: String
    
    internal enum CodingKeys: String, CodingKey {
        case url = "url"
        case method = "method"
    }
}

