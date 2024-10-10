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
    
    @ObservedObject var viewModel: BottomSheetViewModel
    internal let viewController: ViewControllerType
    
    internal init(viewController: ViewControllerType, viewModel: BottomSheetViewModel) {
        self.viewController = viewController
        self.viewModel = viewModel
    }

    internal func makeUIViewController(context: Context) -> UIViewController {
        // Disable scrolling for any UIScrollView within the viewController
        
        if !viewModel.isLandscape {
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
