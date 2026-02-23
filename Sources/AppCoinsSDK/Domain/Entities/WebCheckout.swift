//
//  WebCheckout.swift
//
//
//  Created by Graciano Caldeira on 07/04/2025.
//

import Foundation
import MarketplaceKit

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
    private let platform: String
    private let isBrowserCheckout: String
    private let oemID: String
    private let installationOrigin: String
    
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
        "guestUID" : "guest_uid",
        "version" : "version",
        "langCode" : "lang_code",
        "paymentChannel" : "payment_channel",
        "platform" : "platform",
        "isBrowserCheckout": "is_browser_checkout",
        "oemID": "oem_id",
        "installationOrigin": "installation_origin"
    ]
    
    internal init(
        domain: String,
        product: String,
        metadata: String?,
        reference: String?,
        guestUID: String?,
        type: WebCheckoutType
    ) async {
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
        self.platform = "IOS"
        self.isBrowserCheckout = "\(type == .browser)"
        
        #if targetEnvironment(simulator)
        self.installationOrigin = "com.aptoide.ios.store"
        self.oemID = BuildConfiguration.aptoideOEMID
        #else
        if #available(iOS 17.4, *),
           case .marketplace(let marketplace) = try? await AppDistributor.current {
            self.installationOrigin = marketplace
            self.oemID = marketplace == "com.aptoide.ios.store.jp" ? BuildConfiguration.appArenaOEMID : BuildConfiguration.aptoideOEMID
        } else {
            self.installationOrigin = "com.aptoide.ios.store"
            self.oemID = BuildConfiguration.aptoideOEMID
        }
        #endif
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
        if #available(iOS 16, *) {
            let languageID = Locale.preferredLanguages.first ?? "en-US"
            let locale = Locale(identifier: languageID)
            
            let langCode = locale.language.languageCode?.identifier ?? "en"
            let countryCode = locale.region?.identifier ?? "US"
            
            return (langCode, countryCode)
        } else {
            let languageID = Locale.preferredLanguages.first ?? "en-US"
            let locale = Locale(identifier: languageID)
            
            let langCode = locale.languageCode ?? "en"
            let countryCode = locale.regionCode ?? "US"
            
            return (langCode, countryCode)
        }
    }
    
}
