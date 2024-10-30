//
//  KeyboardObserver.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI

internal class KeyboardObserver: ObservableObject {
    @Published internal var isKeyboardVisible = false
    @Published internal var keyboardHeight: CGFloat = 0
    
    static internal var shared : KeyboardObserver = KeyboardObserver()
    
    internal init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc internal func keyboardWillShow(_ notification: Notification) {
        withAnimation(.easeInOut(duration: 0.2)) {
            isKeyboardVisible = true
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
            }
        }
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isKeyboardVisible = false
                self.keyboardHeight = 0
            }
        }
    }
    
    internal func findFirstResponder(in view: UIView) -> UIResponder? {
        if view.isFirstResponder {
            return view
        }

        for subview in view.subviews {
            if let responder = findFirstResponder(in: subview) {
                return responder
            }
        }

        return nil
    }
}
