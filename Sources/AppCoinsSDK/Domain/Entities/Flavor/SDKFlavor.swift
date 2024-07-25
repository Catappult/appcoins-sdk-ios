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
    
    internal init(mode: FlavorMode = .USER, userFlavor: UserFlavor) {
        self.mode = mode
        self.userFlavor = userFlavor
    }
    
    internal init(mode: FlavorMode = .DEFAULT, defaultFlavor: DefaultFlavor) {
        self.mode = mode
        self.defaultFlavor = defaultFlavor
    }
    
    internal func get() -> Flavor? {
        if let userFlavor = self.userFlavor {
            return Flavor(colorFlavor: userFlavor.get().0, colorMode: userFlavor.get().1)
        } else if let defaultFlavor = self.defaultFlavor {
            return Flavor(colorFlavor: defaultFlavor.flavor, colorMode: defaultFlavor.mode)
        } else { return nil }
    }
}
