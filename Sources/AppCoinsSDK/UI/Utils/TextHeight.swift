//
//  TextHeight.swift
//
//
//  Created by aptoide on 03/01/2025.
//

import SwiftUI

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func minimumHeightNeeded(withConstrainedWidth width: CGFloat, font: UIFont, maxLines: Int) -> CGFloat {
        let maxHeight = font.lineHeight * CGFloat(maxLines)
        
        return min(self.height(withConstrainedWidth: width, font: font), maxHeight)
    }
    
    func numberOfLines(usingFont font: UIFont, withinWidth width: CGFloat) -> Int {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let textSize = (self as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        let lineHeight = font.lineHeight
        let numberOfLines = Int(ceil(textSize.height / lineHeight))
        
        return numberOfLines
    }
}
