//
//  ColorsUi.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI

internal struct ColorsUi {
    // Web Checkout
    static internal var APC_WebViewDarkMode: Color = Color(red: 0.16, green: 0.16, blue: 0.2)
    static internal var APC_WebViewLightMode: Color = Color(red: 0.96, green: 0.96, blue: 0.98)
    
    static internal var APC_Black: Color = Color(red: 0.098, green: 0.137, blue: 0.165, opacity: 1)
    static internal var APC_White: Color = Color(red: 0.96, green: 0.96, blue: 0.98, opacity: 1)
    static internal var APC_BackgroundGray: Color = Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 1)
    static internal var APC_BackgroundLightGray_Button: Color = Color(red: 0.898, green: 0.898, blue: 0.918)
    static internal var APC_BackgroundDarkGray_Button: Color = Color(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2))
    static internal var APC_DarkGray_Xmark: Color = Color(UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1))
    static internal var APC_LightGray_Xmark: Color = Color(UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 1))
    
    // Provider Choice
    static internal var APC_AptoideOrange: Color = Color(red: 0.996, green: 0.392, blue: 0.275)
    static internal var APC_AptoideBlue: Color = Color(red: 0.0, green: 0.4667, blue: 1.0)
    static internal var APC_AptoidePurple: Color = Color(red: 0.31, green: 0.18, blue: 0.98)
    static internal var APC_AptoideGradient: LinearGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(red: 1.00, green: 0.39, blue: 0.27), location: 0.0),
            .init(color: Color(red: 1.00, green: 0.39, blue: 0.27), location: 0.75),
            .init(color: Color(red: 1.00, green: 0.16, blue: 0.00), location: 0.8846)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

