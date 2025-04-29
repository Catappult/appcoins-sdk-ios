//
//  PurchaseIntentService.swift
//
//
//  Created by aptoide on 17/04/2025.
//

import Foundation

internal protocol PurchaseIntentService {
    
    func persist(intent: PurchaseIntent)
    func fetch() -> PurchaseIntent?
    func remove()
    
}
