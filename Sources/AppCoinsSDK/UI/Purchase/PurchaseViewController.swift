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
        let bottomSheetView = BottomSheetView(dismiss: self.dismissPurchase)
        let content: () -> UIView = {
            return bottomSheetView.toUIView()
        }
        let wrapperView = BottomSheetWrapperView(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func dismissPurchase() {
        self.dismiss(animated: false, completion: nil)
    }
}
