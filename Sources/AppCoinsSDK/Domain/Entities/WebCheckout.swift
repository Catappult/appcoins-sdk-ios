//
//  WebCheckout.swift
//
//
//  Created by Graciano Caldeira on 07/04/2025.
//

import Foundation

internal struct WebCheckout {
    
    private let origin: String
    private let type: String
    private let domain: String
    private let product: String
    private var country: String
    private let metadata: String?
    private let reference: String?
    private let guestUID: String?
    private let version: String
    private var langCode: String
    private let paymentChannel: String
    
    internal var URL: URL? {
        var components = URLComponents(string: BuildConfiguration.webCheckoutURL)
        components?.queryItems = asQueryItems()
        return components?.url
    }
    
    private let queryKeys: [String : String] = [
        "origin" : "origin",
        "type" : "type",
        "domain" : "domain",
        "product" : "product",
        "country" : "country",
        "metadata" : "metadata",
        "reference" : "reference",
        "guestUID" : "guest_id",
        "version" : "version",
        "langCode" : "lang_code",
        "paymentChannel" : "payment_channel"
    ]
    
    internal init(domain: String, product: String, metadata: String?, reference: String?, guestUID: String?) {
        self.origin = "BDS"
        self.type = "INAPP"
        self.domain = domain
        self.product = product
        self.country = WebCheckout.getLangAndCountry().countryCode
        self.metadata = metadata
        self.reference = reference
        self.guestUID = guestUID
        self.version = String(describing: BuildConfiguration.sdkBuildNumber)
        self.langCode = WebCheckout.getLangAndCountry().langCode
        self.paymentChannel = "ios_sdk"
    }
    
    private func asQueryItems() -> [URLQueryItem] {
        let mirror = Mirror(reflecting: self)
        
        return mirror.children.compactMap { (label, value) in
            guard let label = label, let value = value as? String else { return nil }
            
            if let mappedKey = queryKeys[label] { return URLQueryItem(name: mappedKey, value: value) }
            
            return nil
        }
    }
    
    private static func getLangAndCountry() -> (langCode: String, countryCode: String) {
        var langCode: String = ""
        var countryCode: String = ""
        if #available(iOS 16, *) {
            let languageID = Locale.preferredLanguages.first ?? "en-US"
            let locale = Locale(identifier: languageID)
            
            langCode = locale.language.languageCode?.identifier ?? "en"
            countryCode = locale.region?.identifier ?? "US"
        } else {
            langCode = "en"
            countryCode = "US"
        }
        return (langCode, countryCode)
    }
    
}
