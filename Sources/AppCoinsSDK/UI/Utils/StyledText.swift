//
//  StyledText.swift
//  
//
//  Created by aptoide on 12/10/2023.
//

import SwiftUI

/**
 A custom SwiftUI view for displaying styled text with varying fonts and colors.

 Use `StyledText` to create a text view with portions of text styled differently. This view is designed to handle text strings with alternating regular and bold styles.

 - Parameters:
   - localizedString: The localized string containing text to style. It should use `*` to denote where the bold style should be applied.
   - textStyle: The font style for regular text.
   - boldStyle: The font style for bold text.
   - textColorRegular: The color for regular text.
   - textColorBold: The color for bold text.

 `StyledText` splits the `localizedString` at `*` characters and applies the specified `textStyle` and `boldStyle` to the respective portions of text. The `textColorRegular` and `textColorBold` parameters allow you to customize the text colors for regular and bold text.

 Example usage:
 ```swift
 let localizedString = "**New** movies"
 let textStyle = Font.system(size: 16)
 let boldStyle = Font.system(size: 16).bold()
 let textColorRegular = Color.blue
 let textColorBold = Color.red

 let styledTextView = StyledText(localizedString, textStyle: textStyle, boldStyle: boldStyle, textColorRegular: textColorRegular, textColorBold: textColorBold)

 // In your SwiftUI view hierarchy, you can use styledTextView as a Text view.
 Note: Make sure to use * characters in the localizedString to indicate where the bold style should be applied.

 */
internal struct StyledText: View {
    private let localizedString: String
    private let textStyle: Font
    private let boldStyle: Font
    private let textColorRegular: Color
    private let textColorBold: Color
    
    internal init(_ localizedString: String, textStyle: Font, boldStyle: Font, textColorRegular: Color, textColorBold: Color) {
        self.localizedString = localizedString
        self.textStyle = textStyle
        self.boldStyle = boldStyle
        self.textColorRegular = textColorRegular
        self.textColorBold = textColorBold
    }
    
    internal var body: some View {
        let parts = localizedString.split(separator: "*")
        var textArray: [Text] = []

        for (index, part) in parts.enumerated() {
            if index % 2 == 0 {
                // Regular text
                textArray.append(Text(part).font(textStyle).foregroundColor(textColorRegular))
            } else {
                // Bold text
                textArray.append(Text(part).font(boldStyle).foregroundColor(textColorBold))
            }
        }

        return textArray.reduce(Text("")) { (result, text) in
            result + text
        }
    }
}
