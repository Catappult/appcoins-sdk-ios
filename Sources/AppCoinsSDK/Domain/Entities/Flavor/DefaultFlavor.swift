//
//  DefaultFlavor.swift
//
//
//  Created by Graciano Caldeira on 24/07/2024.
//

import Foundation

internal struct DefaultFlavor {

    internal let flavor: ColorFlavor
    internal let mode: ColorMode
    
    internal init(flavor: ColorFlavor, mode: ColorMode) {
        self.flavor = flavor
        self.mode = mode
    }
    
    internal func get() -> (ColorFlavor, ColorMode) {
        return (self.flavor, self.mode)
    }
}

