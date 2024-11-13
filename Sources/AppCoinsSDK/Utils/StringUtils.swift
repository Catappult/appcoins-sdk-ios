//
//  StringUtils.swift
//
//
//  Created by Graciano Caldeira on 13/11/2024.
//

import Foundation

internal struct StringUtils {
    
    static internal func cleanAndFormatJSON(in response: String) -> String {
        // Remove HTML tags
        var cleanedResponse = response
            .replacingOccurrences(of: "<br />", with: "")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "\\/", with: "/")
        
        // Regular expression to identify JSON objects and format them
        let objectPattern = "\\{([^\\{\\}]*)\\}"
        
        if let objectRegex = try? NSRegularExpression(pattern: objectPattern, options: []) {
            let matches = objectRegex.matches(in: cleanedResponse, options: [], range: NSRange(location: 0, length: cleanedResponse.utf16.count))
            
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: cleanedResponse) {
                    let objectContent = cleanedResponse[range]
                    
                    // Each key-value pair on a new line
                    let formattedObject = objectContent
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .joined(separator: ",\n    ")
                    
                    // Formatted content in the original string
                    cleanedResponse.replaceSubrange(range, with: "\n    \(formattedObject)\n")
                }
            }
        }
        return cleanedResponse
    }
}
