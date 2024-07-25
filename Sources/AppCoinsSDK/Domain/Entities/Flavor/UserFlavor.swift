//
//  UserFlavor.swift
//
//
//  Created by Graciano Caldeira on 24/07/2024.
//

import Foundation

internal struct UserFlavor {
    
    internal let lightMode: ColorFlavor
    internal let darkMode: ColorFlavor
    
    init(lightMode: ColorFlavor, darkMode: ColorFlavor) {
        self.lightMode = lightMode
        self.darkMode = darkMode
    }
    
    internal func get() -> (ColorFlavor, ColorMode) {
        if self.getUserMode() == .LIGHT {
            return (self.lightMode, .LIGHT)
        } else {
            return (self.darkMode, .DARK)
        }
    }
    
    private func getUserMode() -> ColorMode {
        if BuildConfiguration.userColorScheme == .light {
            return .LIGHT
        } else {
            return .DARK
        }
    }
}
