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

        view.backgroundColor = UIColor(color: ColorsUi.APC_WebViewLightMode)
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.insetsLayoutMarginsFromSafeArea = false

        let hosting = UIHostingController(rootView: WebCheckoutView().ignoresSafeArea(edges: .bottom))
        addChild(hosting)
        view.addSubview(hosting.view)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
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
