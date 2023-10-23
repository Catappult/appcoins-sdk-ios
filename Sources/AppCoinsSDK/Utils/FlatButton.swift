//
//  FlatButton.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI

internal struct flatButtonStyle: ButtonStyle {
    internal func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
