//
//  BottomSheetViewController.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 20/05/2025.
//

import SwiftUI
@_implementationOnly import WebKit

internal class BottomSheetViewController: UIViewController {
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.insetsLayoutMarginsFromSafeArea = false

        let hosting = UIHostingController(rootView: WebCheckoutViewWrapper(background: traitCollection.userInterfaceStyle == .dark ? ColorsUi.APC_WebViewDarkMode : ColorsUi.APC_WebViewLightMode))
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = UIColor(color: ColorsUi.APC_WebViewLightMode)
        view.addSubview(spacer)
        
        addChild(hosting)
        view.addSubview(hosting.view)
        
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacer.topAnchor.constraint(equalTo: view.topAnchor),
            spacer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spacer.heightAnchor.constraint(equalToConstant: 20),
            
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hosting.didMove(toParent: self)
    }
    
    @objc private func dismissSheet() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
}


