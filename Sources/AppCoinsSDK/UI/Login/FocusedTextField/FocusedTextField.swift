//
//  FocusableTextField.swift
//  
//
//  Created by Graciano Caldeira on 18/12/2024.
//

import SwiftUI
import UIKit

struct FocusableTextField: UIViewRepresentable {
    
    @ObservedObject internal var authViewModel: AuthViewModel
    internal var placeholder: String
    @Binding internal var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.becomeFirstResponder()
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator { Coordinator(self, authViewModel: authViewModel) }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
        var authViewModel: AuthViewModel
        private var keyboardWillHideObserver: NSObjectProtocol?
        
        init(_ parent: FocusableTextField, authViewModel: AuthViewModel) {
            self.parent = parent
            self.authViewModel = authViewModel
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
                authViewModel.hideFocusedTextField()
            }
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            let filteredText = textField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            if parent.text != filteredText {
                parent.text = filteredText
                textField.text = filteredText
            }
        }
        
        // Keyboard is dismissed after pressing enter/return
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            withAnimation(.easeInOut(duration: 0.4)) {
                authViewModel.hideFocusedTextField()
            }
            textField.resignFirstResponder()
            return true
        }
    }
}
