//
//  ColorFlavor.swift
//
//
//  Created by Graciano Caldeira on 24/07/2024.
//

import Foundation

internal struct ColorFlavor {
    
    internal let buttonColor: APPCColor
    internal let backgroundColor: APPCColor
    internal let bannerColor: APPCColor
    internal let paymentColor: APPCColor
    
    init(buttonColor: APPCColor, backgroundColor: APPCColor, brandingColor: APPCColor, paymentColor: APPCColor) {
        self.buttonColor = buttonColor
        self.backgroundColor = backgroundColor
        self.bannerColor = brandingColor
        self.paymentColor = paymentColor
    }
}
