//
//  Flavor.swift
//
//
//  Created by Graciano Caldeira on 24/07/2024.
//

import Foundation

internal struct Flavor {
    
    internal let colorFlavor: ColorFlavor
    internal let colorMode: ColorMode
    
    internal init(colorFlavor: ColorFlavor, colorMode: ColorMode) {
        self.colorFlavor = colorFlavor
        self.colorMode = colorMode
    }
}
