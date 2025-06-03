//
//  CornerRadiusExtension.swift
//  AppCoinsSDK
//
//  Created by aptoide on 02/06/2025.
//

import SwiftUI

internal extension View {
    internal func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

internal struct RoundedCorner: Shape {

    internal var radius: CGFloat = .infinity
    internal var corners: UIRectCorner = .allCorners

    internal func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
