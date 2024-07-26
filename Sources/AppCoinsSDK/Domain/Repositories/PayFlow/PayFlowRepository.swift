//
//  PayFlowRepository.swift
//
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal class PayFlowRepository: PayFlowRepositoryProtocol {
    
    private let PayFlowService: PayFlowService = PayFlowClient()
    
    internal func setPayFlow() {
        
        let oemID = UserDefaults.standard.string(forKey: "attribution-oemid")
        
        self.PayFlowService.setPayFlow(package: BuildConfiguration.packageName, packageVercode: BuildConfiguration.packageVersion, sdkVercode: BuildConfiguration.vercode, locale: nil, oemID: oemID, oemIDType: nil, country: nil, os: "ios") { result in
            switch result {
            case .success(let payFlowDataRaw):
                try? Utils.writeToPreferences(key: "pay-flow-method", value: payFlowDataRaw.paymentFlow)
            case .failure:
                break
            }
        }
    }
    
    func getPayFlow() -> PayFlowType {
        
        if Utils.readFromPreferences(key: "pay-flow-method") == PayFlowType.d2c.rawValue {
            return .d2c
        } else { return .standard }
    }
}
