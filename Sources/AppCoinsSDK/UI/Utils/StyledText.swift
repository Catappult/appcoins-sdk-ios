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
   - localizedString: The localized string containing text to style. It should use `*` to denote where the bold style should be applied. The bold portions can be denoted by a single `*` at the beginning and end or surrounded by `*` characters. Examples: "*New* movies", "This is *an example* for you", "*This is an example* for you", "This is an example *for you*".
   - textStyle: The font style for regular text.
   - boldStyle: The font style for bold text.
   - textColorRegular: The color for regular text.
   - textColorBold: The color for bold text.

 `StyledText` intelligently identifies and applies the specified `textStyle` and `boldStyle` to the respective portions of text in the `localizedString`. The `textColorRegular` and `textColorBold` parameters allow you to customize the text colors for regular and bold text.

 Example usage:
 ```swift
 let localizedString = "*New* movies"
 let textStyle = Font.system(size: 16)
 let boldStyle = Font.system(size: 16).bold()
 let textColorRegular = Color.blue
 let textColorBold = Color.red

 let styledTextView = StyledText(localizedString, textStyle: textStyle, boldStyle: boldStyle, textColorRegular: textColorRegular, textColorBold: textColorBold)

 // In your SwiftUI view hierarchy, you can use styledTextView as a Text view.
 Note: Make sure to use * characters in the localizedString to indicate where the bold style should be applied. The bold portions can be either surrounded by * characters or indicated with a single * at the beginning and end of the bold text.

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
        var textArray: [Text] = []
        
        let boldRanges = findBoldRanges(localizedString)
        var currentIndex = localizedString.startIndex
        
        for range in boldRanges {
            // Add regular text before the bold section, excluding any asterisks
            if currentIndex < range.lowerBound {
                let part = String(localizedString[currentIndex..<range.lowerBound]).trimmingCharacters(in: CharacterSet(charactersIn: "*"))
                textArray.append(Text(part).font(textStyle).foregroundColor(textColorRegular))
            }
            
            // Add bold text, excluding the asterisks
            let part = String(localizedString[range]).trimmingCharacters(in: CharacterSet(charactersIn: "*"))
            textArray.append(Text(part).font(boldStyle).foregroundColor(textColorBold))
            
            currentIndex = range.upperBound
        }
        
        // Add any remaining regular text after the last bold section, excluding any asterisks
        if currentIndex < localizedString.endIndex {
            let part = String(localizedString[currentIndex...]).trimmingCharacters(in: CharacterSet(charactersIn: "*"))
            textArray.append(Text(part).font(textStyle).foregroundColor(textColorRegular))
        }
        
        return textArray.reduce(Text("")) { (result, text) in
            result + text
        }
    }

    
    private func findBoldRanges(_ string: String) -> [Range<String.Index>] {
        var boldRanges: [Range<String.Index>] = []
        var currentIndex = string.startIndex

        while let startRange = string[currentIndex...].range(of: "*") {
            let startIndex = startRange.lowerBound
            currentIndex = string.index(after: startIndex)

            if let endRange = string[currentIndex...].range(of: "*") {
                let boldStart = currentIndex
                let boldEnd = endRange.lowerBound

                boldRanges.append(boldStart..<boldEnd)
                currentIndex = string.index(after: boldEnd)
            } else {
                // No closing asterisk found, so we break the loop
                break
            }
        }
        
        return boldRanges
    }

}
