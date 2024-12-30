//
//  PurchaseView.swift
//
//
//  Created by Graciano Caldeira on 04/10/2024.
//

import SwiftUI
@_implementationOnly import ActivityIndicatorView

struct PayingView: View {
    internal var body: some View {
        ZStack {
            PayingViewFormLayer()
            PayingViewButtonLayer()
        }.frame(maxHeight: .infinity, alignment: .bottom)
    }
}
