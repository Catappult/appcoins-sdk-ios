//
//  BlurView.swift
//  
//
//  Created by Graciano Caldeira on 03/10/2024.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        if let style = style {
            view.effect = UIBlurEffect(style: style)
        } else {
            view.effect = nil
        }
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if let style = style {
            uiView.effect = UIBlurEffect(style: style)
        } else {
            uiView.effect = nil
        }
    }
}
