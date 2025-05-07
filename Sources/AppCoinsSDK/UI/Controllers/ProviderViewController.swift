//
//  ProviderViewController.swift
//  
//
//  Created by aptoide on 05/05/2025.
//

import Foundation
import SwiftUI

internal class ProviderViewController: UIViewController {
    
    @ObservedObject private var keyboardObserver = KeyboardObserver.shared
    internal var orientation: UIInterfaceOrientationMask = .landscape
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        updateOrientation()
        
        // Add the bottom sheet view
        let providerBottomSheet = ProviderBottomSheet()
        let content: () -> UIView = {
            return providerBottomSheet.toUIView()
        }
        let wrapperView = ProviderBottomSheetWrapper(content: content)
        self.view.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: self.view.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func updateOrientation() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if scene.interfaceOrientation == .landscapeLeft || scene.interfaceOrientation == .landscapeRight {
                ProviderViewModel.shared.setOrientation(orientation: .landscape)
                orientation = .landscape
            } else {
                ProviderViewModel.shared.setOrientation(orientation: .portrait)
                orientation = .portrait
            }
        }
    }
    
    override internal var supportedInterfaceOrientations: UIInterfaceOrientationMask { return orientation }
    
    @objc internal func dismissProviderChoice(completion: @escaping () -> Void) { self.dismiss(animated: true, completion: completion) }
    
}
