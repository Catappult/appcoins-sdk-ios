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
    internal let orientation: Orientation
    
    internal init(viewController: ViewControllerType, orientation: Orientation) {
        self.viewController = viewController
        self.orientation = orientation
    }

    internal func makeUIViewController(context: Context) -> UIViewController {
        // Disable scrolling for any UIScrollView within the viewController
        
        if orientation == .portrait {
            disableScrollingInView(viewController.view)
        }
        
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
