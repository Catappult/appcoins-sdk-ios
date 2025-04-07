//
//  SetExternalNavigation.swift
//
//
//  Created by aptoide on 07/04/2025.
//

import Foundation

internal class SetExternalNavigation {
    
    internal static func handle(body: SetExternalNavigationBody) {
        SDKUseCases.shared.setExternalNavigation(externalNavigation: ExternalNavigation(raw: body))
    }
    
}
