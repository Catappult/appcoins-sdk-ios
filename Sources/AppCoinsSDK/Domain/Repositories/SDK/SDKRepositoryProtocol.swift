//
//  SDKRepositoryProtocol.swift
//  
//
//  Created by Graciano Caldeira on 20/02/2025.
//

import Foundation

internal protocol SDKRepositoryProtocol {
    func isDefault() -> Bool?
    func setSDKDefault(value: Bool)
    func setExternalNavigation(externalNavigation: ExternalNavigation)
    func getExternalNavigation() -> ExternalNavigation?
}
