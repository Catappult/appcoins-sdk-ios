//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        AttributionUseCases.shared.getAttribution { result in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
}
