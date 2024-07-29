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
        if self.getUserMode() == .light {
            return (self.lightMode, .light)
        } else {
            return (self.darkMode, .dark)
        }
    }
    
    private func getUserMode() -> ColorMode {
        if BuildConfiguration.userColorScheme == .dark {
            return .dark
        } else { return .light }
    }
}
