//
//  LegacyPassthroughViewController.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 20/05/2025.
//

import UIKit

internal class LegacyPassthroughViewController: UIViewController {
    var onAppear: (() -> Void)?
    var onDismissBinding: (() -> Void)?

    private var hasAppeared = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasAppeared else { return }
        hasAppeared = true

        DispatchQueue.main.async {
            self.onAppear?()
        }
    }
}
