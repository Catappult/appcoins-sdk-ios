//
//  BottomSheetPresentationController.swift
//  AppCoinsSDK
//
//  Created by Graciano Caldeira on 20/05/2025.
//

import UIKit

internal class BottomSheetPresentationController: UIPresentationController {
    private let dimmingView = UIView()

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }

        let isLandscape = container.bounds.width > container.bounds.height
        let height: CGFloat = isLandscape ? container.bounds.height * 0.9 : container.bounds.height * 0.6
        let width: CGFloat = isLandscape ? container.bounds.width - 176 : container.bounds.width
        let x: CGFloat = isLandscape ? (container.bounds.width - width) / 2 : 0

        return CGRect(
            x: x,
            y: container.bounds.height - height,
            width: width,
            height: height
        )
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView else { return }

        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        dimmingView.frame = container.bounds

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        dimmingView.addGestureRecognizer(tap)

        container.addSubview(dimmingView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    @objc private func handleTapOutside() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
