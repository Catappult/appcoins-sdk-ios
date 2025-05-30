//
//  LegacyBottomSheetPresenter.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 20/05/2025.
//

import UIKit
import SwiftUI

internal struct LegacyBottomSheetPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> LegacyPassthroughViewController {
        let vc = LegacyPassthroughViewController()

        vc.onAppear = {
            context.coordinator.tryPresent(from: vc, isPresented: isPresented)
        }

        vc.onDismissBinding = {
            DispatchQueue.main.async {
                self.isPresented = false
            }
        }

        context.coordinator.parentVC = vc
        return vc
    }

    func updateUIViewController(_ uiViewController: LegacyPassthroughViewController, context: Context) {
        context.coordinator.tryPresent(from: uiViewController, isPresented: isPresented)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        weak var parentVC: UIViewController?
        private var isPresented: Binding<Bool>

        init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }
        
        func tryPresent(from vc: UIViewController, isPresented: Bool) {
            guard isPresented else { return }

            if let alreadyPresented = vc.presentedViewController, !alreadyPresented.isBeingDismissed {
                return
            }

            guard vc.view.window != nil else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.tryPresent(from: vc, isPresented: isPresented)
                }
                return
            }
            
            if let alreadyPresented = vc.presentedViewController {
                if alreadyPresented.isBeingPresented || !alreadyPresented.isBeingDismissed {
                    return
                }
            }

            let sheet = LegacyBottomSheetViewController()
            sheet.modalPresentationStyle = .custom
            sheet.transitioningDelegate = self

            sheet.onDismiss = { [weak self] in
                DispatchQueue.main.async {
                    self?.isPresented.wrappedValue = false
                    PurchaseViewModel.shared.cancel()
                }
            }

            vc.present(sheet, animated: true)
        }
        
        func presentationController(forPresented presented: UIViewController,
                                    presenting: UIViewController?,
                                    source: UIViewController) -> UIPresentationController? {
            LegacyBottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
}
