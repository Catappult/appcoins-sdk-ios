//
//  BottomSheetWrapperView.swift
//  
//
//  Created by aptoide on 07/03/2023.
//

import Foundation
import UIKit

internal class BottomSheetWrapperView<Content: UIView>: UIView {
    internal let contentView: Content
    
    internal init(content: @escaping () -> Content) {
        self.contentView = content()
        super.init(frame: .zero)
        self.setup()
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
