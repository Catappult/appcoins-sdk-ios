//
//  FlatButton.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI

internal struct flatButtonStyle: SwiftUI.ButtonStyle {
    internal func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
        configuration.label
    }
}
