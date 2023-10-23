//
//  AdyenControllerWrapper.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation
import SwiftUI
import UIKit

internal struct AdyenViewControllerWrapper<ViewControllerType: UIViewController>: UIViewControllerRepresentable {
    internal let viewController: ViewControllerType
    
    internal init(viewController: ViewControllerType) {
        self.viewController = viewController
    }

    internal func makeUIViewController(context: Context) -> UIViewController {
        // Disable scrolling for any UIScrollView within the viewController
        disableScrollingInView(viewController.view)
        
        return viewController
    }

    internal func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update any data if necessary
    }
    
    private func disableScrollingInView(_ view: UIView) {
        if let scrollView = view as? UIScrollView {
            scrollView.isScrollEnabled = false
        } else {
            view.subviews.forEach { disableScrollingInView($0) }
        }
    }
}
