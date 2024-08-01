//
//  SDKFlavor.swift
//  
//
//  Created by Graciano Caldeira on 24/07/2024.
//

import Foundation

internal struct SDKFlavor {
    
    internal var defaultFlavor: DefaultFlavor? = nil
    internal var userFlavor: UserFlavor? = nil
    internal var mode: FlavorMode
    
    internal init(mode: FlavorMode = .user, userFlavor: UserFlavor) {
        self.mode = mode
        self.userFlavor = userFlavor
    }
    
    internal init(mode: FlavorMode = .standard, defaultFlavor: DefaultFlavor) {
        self.mode = mode
        self.defaultFlavor = defaultFlavor
    }
    
    internal func get() -> Flavor? {
        if let (colorFlavor, colorMode) = self.userFlavor?.get() {
            return Flavor(colorFlavor: colorFlavor, colorMode: colorMode)
        } else { return nil }
    }
}
