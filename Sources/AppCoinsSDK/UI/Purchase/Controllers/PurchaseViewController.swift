//
//  PurchaseViewController.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import SwiftUI

class PurchaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the bottom sheet view
        let bottomSheetView = BottomSheetView(viewModel: BottomSheetViewModel(dismiss: self.dismissPurchase))
        let content: () -> UIView = {
            return bottomSheetView.toUIView()
        }
        let wrapperView = BottomSheetWrapperView(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: self.view.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    @objc private func dismissPurchase() {
        self.dismiss(animated: false, completion: nil)
    }
}
