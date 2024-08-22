//
//  AppcSDKInternal.swift
//
//
//  Created by Graciano Caldeira on 11/07/2024.
//

import Foundation

internal class AppcSDKInternal {
    
    static internal func initialize() {
        MMPUseCases.shared.getAttribution()
        AnalyticsUseCases.shared.initialize()
        CurrencyUseCases.shared.getSupportedCurrencies { result in
            switch result {
            case .success(let success):
                print("temos dados: \(success)")
            case .failure(let error):
                print("falhou: \(error)")
            }
        }
    }
}
