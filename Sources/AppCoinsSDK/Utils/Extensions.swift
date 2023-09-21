//
//  File.swift
//  
//
//  Created by aptoide on 21/09/2023.
//

import SwiftUI

extension UIView {
    func findAndResignFirstResponder() {
        if isFirstResponder {
            resignFirstResponder()
        } else {
            for subview in subviews {
                subview.findAndResignFirstResponder()
            }
        }
    }
}
