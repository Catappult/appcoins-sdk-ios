//
//  TextFieldAlert.swift
//  AppCoinsSDK
//
//  Created by aptoide on 23/05/2025.
//

import SwiftUI

final class TextFieldAlert {
    private var window: UIWindow?

    func present(title: String,
                 message: String,
                 placeholder: String? = nil,
                 confirmLabel: String,
                 cancelLabel: String,
                 shouldBeEnabled: @escaping (String) -> Bool = { _ in true },
                 confirmAction: @escaping (String) -> Void,
                 cancelAction: @escaping () -> Void) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var textObserver: NSObjectProtocol?

        // Add the Destructive/OK action first so we can reference it easily
        let okAction = UIAlertAction(title: confirmLabel, style: .destructive) { _ in
            confirmAction(alert.textFields?.first?.text ?? "")
            self.cleanup(textObserver)
        }
        alert.addAction(okAction)

        // Optionally add a text field and hook up validation
        if let placeholder = placeholder {
            alert.addTextField { tf in
                tf.placeholder = placeholder
                textObserver = NotificationCenter.default.addObserver(
                    forName: UITextField.textDidChangeNotification,
                    object: tf,
                    queue: .main
                ) { _ in
                    okAction.isEnabled = shouldBeEnabled(tf.text ?? "")
                }
            }
            // Disable the OK button until validation passes
            okAction.isEnabled = false
        }

        alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel) { _ in
            cancelAction()
            self.cleanup(textObserver)
        })

        // Obtain the active windowScene so the temporary window is actually shown
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
        else { return }

        let tempWindow = UIWindow(windowScene: windowScene)
        tempWindow.frame = UIScreen.main.bounds
        tempWindow.windowLevel = .alert + 1

        let hostVC = UIViewController()
        tempWindow.rootViewController = hostVC
        self.window = tempWindow

        tempWindow.makeKeyAndVisible()
        hostVC.present(alert, animated: true)
    }

    private func cleanup(_ observer: NSObjectProtocol?) {
        if let observer { NotificationCenter.default.removeObserver(observer) }
        window?.isHidden = true
        window = nil
    }
}
