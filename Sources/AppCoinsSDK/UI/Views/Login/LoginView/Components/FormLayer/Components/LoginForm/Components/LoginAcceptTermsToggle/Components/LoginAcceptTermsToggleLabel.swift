//
//  LoginAcceptTermsToggleLabel.swift
//
//
//  Created by aptoide on 09/01/2025.
//

import SwiftUI

internal struct LoginAcceptTermsToggleLabel: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    
    private var acceptTermsLabelFirstPart: String? = nil
    private var acceptTermsLabelSecondPart: String? = nil
    private var acceptTermsLabelThirdPart: String? = nil
    private var numberOfLines: Int = 0
    private var firstLineLength: Int = 0
    private var labelHeight: CGFloat = 0
    private var labelComponents: [(String, URL?)] = []
    
    internal init() {
        let acceptTermsTextRanges: [Range<String.Index>] = ranges(Constants.acceptTermsBody, of: "%@")
        
        guard acceptTermsTextRanges.count > 1 else { return } // Ensure the array has at least two elements
        let firstRange = acceptTermsTextRanges[0]
        let secondRange = acceptTermsTextRanges[1]
        
        self.acceptTermsLabelFirstPart = String(Constants.acceptTermsBody[..<firstRange.lowerBound])
        self.acceptTermsLabelSecondPart = String(Constants.acceptTermsBody[firstRange.upperBound..<secondRange.lowerBound])
        self.acceptTermsLabelThirdPart = String(Constants.acceptTermsBody[secondRange.upperBound...])
        
        var totalLabel: [String] = [self.acceptTermsLabelFirstPart, Constants.termsAndConditions, self.acceptTermsLabelSecondPart, Constants.privacyPolicy, self.acceptTermsLabelThirdPart].compactMap { $0 } // Compact map to remove nil elements
        
        for component in totalLabel {
            if component == Constants.termsAndConditions { labelComponents.append((component, URL(string: "https://en.aptoide.com/company/legal?section=terms"))) }
            else if component == Constants.privacyPolicy { labelComponents.append((component, URL(string: "https://en.aptoide.com/company/legal?section=privacy"))) }
            else { labelComponents.append((component, nil)) }
        }
        
        let availableWidth = viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 - 40 : UIScreen.main.bounds.width - 48 - 40
        
        var fits = true
        for i in 0...totalLabel.count {
            let firstLineAttempt = totalLabel.prefix(i).joined(separator: "")
            let numberOfLines = firstLineAttempt.numberOfLines(usingFont: UIFont.systemFont(ofSize: 12, weight: .regular), withinWidth: availableWidth)
            
            if numberOfLines > 1 {
                self.numberOfLines = 2
                self.firstLineLength = i - 1
                fits = false
                break
            }
        }
        
        if fits {
            self.numberOfLines = 1
            self.firstLineLength = totalLabel.count
        }
        
        self.labelHeight = totalLabel.joined(separator: "").height(
            withConstrainedWidth: availableWidth,
            font: UIFont.systemFont(ofSize: 12, weight: .regular)
        )
    }
    
    internal func ranges(_ searchString: String, of breakString: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var startIndex = searchString.startIndex
        
        while startIndex < searchString.endIndex,
              let range = searchString.range(of: breakString, range: startIndex..<searchString.endIndex) {
            ranges.append(range)
            startIndex = range.upperBound
        }
        
        return ranges
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            // First Row
            HStack(spacing: 0) {
                ForEach(0..<self.firstLineLength, id: \.self) { index in
                    let component = self.labelComponents[index]
                    let isLastInLine = index == self.firstLineLength - 1 // Check if it's the last element in the line
                    
                    if let url: URL = component.1 {
                        Text(component.0)
                            .onTapGesture { UIApplication.shared.open(url) }
                            .foregroundColor(ColorsUi.APC_Pink)
                    } else {
                        Text(isLastInLine ? component.0.stripTrailingSpace() : component.0) // Trim if last
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .trailing)
            
            if self.numberOfLines > 1 {
                // Second Row
                HStack(spacing: 0) {
                    ForEach(self.firstLineLength..<self.labelComponents.count, id: \.self) { index in
                        let component = self.labelComponents[index]
                        let isLastInLine = index == self.labelComponents.count - 1 // Check if it's the last element in the line
                        
                        if let url: URL = component.1 {
                            Text(component.0)
                                .onTapGesture { UIApplication.shared.open(url) }
                                .foregroundColor(ColorsUi.APC_Pink)
                        } else {
                            Text(isLastInLine ? component.0.stripTrailingSpace() : component.0) // Trim if last
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }
        }.frame(height: self.labelHeight)
    }
}
