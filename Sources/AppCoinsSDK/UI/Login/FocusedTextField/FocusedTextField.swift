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
    @Binding internal var shouldFocus: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text

        if shouldFocus {
            uiView.becomeFirstResponder()
            shouldFocus = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, authViewModel: authViewModel)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
        var authViewModel: AuthViewModel
        
        init(_ parent: FocusableTextField, authViewModel: AuthViewModel) {
            self.parent = parent
            self.authViewModel = authViewModel
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        // Delete all spaces entered by the user
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.contains(" ") {
                return false
            }
            return true
        }
        
        // Keyboard is dismissed after pressing enter/return
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            authViewModel.hideTextFieldView()
            textField.resignFirstResponder()
            return true
        }
    }
}
