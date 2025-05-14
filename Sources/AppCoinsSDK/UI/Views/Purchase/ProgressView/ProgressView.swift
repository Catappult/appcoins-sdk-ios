//
//  ProgressView.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 14/05/2025.
//

import SwiftUI

struct ProgressView: UIViewRepresentable {
    var isAnimating: Bool = true
    var color: UIColor = .white
    var style: UIActivityIndicatorView.Style = .medium

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        if isAnimating {
            indicator.startAnimating()
        }
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.color = color
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
