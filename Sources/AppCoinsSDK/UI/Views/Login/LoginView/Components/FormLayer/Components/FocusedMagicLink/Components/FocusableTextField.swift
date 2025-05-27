//
//  FocusableTextField.swift
//  
//
//  Created by Graciano Caldeira on 18/12/2024.
//

import SwiftUI
import UIKit

internal struct FocusableTextField: UIViewRepresentable {
    
    internal var hide: () -> Void
    internal var placeholder: String
    @Binding internal var text: String

    internal func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.becomeFirstResponder()
        return textField
    }

    internal func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    internal func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    internal class Coordinator: NSObject, UITextFieldDelegate {
        internal var parent: FocusableTextField
        private var keyboardWillHideObserver: NSObjectProtocol?
        
        internal init(_ parent: FocusableTextField) {
            self.parent = parent
            super.init()
            
            // Add observer for keyboard dismissal
            keyboardWillHideObserver = NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.keyboardDidHide()
            }
        }
        
        deinit {
            if let observer = keyboardWillHideObserver { NotificationCenter.default.removeObserver(observer) } // Remove observer
        }
        
        private func keyboardDidHide() {
            withAnimation(.easeInOut(duration: 0.4)) {
                parent.hide()
            }
        }
        
        internal func textFieldDidChangeSelection(_ textField: UITextField) {
            let filteredText = textField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            if parent.text != filteredText {
                parent.text = filteredText
                textField.text = filteredText
            }
        }
        
        // Keyboard is dismissed after pressing enter/return
        internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            withAnimation(.easeInOut(duration: 0.4)) {
                parent.hide()
            }
            textField.resignFirstResponder()
            return true
        }
    }
}
