//
//  ColorFlavor.swift
//
//
//  Created by Graciano Caldeira on 24/07/2024.
//

import Foundation
import SwiftUI

internal struct ColorFlavor {
    
    internal let buttonColor: ColorsUi
    internal let backgroundColor: ColorsUi
    internal let bannerColor: ColorsUi
    internal let paymentColor: ColorsUi
    
    init(buttonColor: ColorsUi, backgroundColor: ColorsUi, brandingColor: ColorsUi, paymentColor: ColorsUi) {
        self.buttonColor = buttonColor
        self.backgroundColor = backgroundColor
        self.bannerColor = brandingColor
        self.paymentColor = paymentColor
    }
}
