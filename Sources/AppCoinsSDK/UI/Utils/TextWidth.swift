//
//  TextWidth.swift
//  
//
//  Created by Graciano Caldeira on 24/02/2025.
//

import SwiftUI

extension String {
    func exactWidth(using font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        return ceil(CTLineGetTypographicBounds(line, nil, nil, nil))
    }
}
