//
//  PayFlowRepository.swift
//
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal class PayFlowRepository: PayFlowRepositoryProtocol {
    
    private let PayFlowService: PayFlowService = PayFlowClient()
    
    internal func setPayFlow(oemID: String) {
        self.PayFlowService.setPayFlow(package: BuildConfiguration.packageName, packageVercode: BuildConfiguration.packageVersion, sdkVercode: BuildConfiguration.vercode, locale: Locale.current.regionCode?.lowercased(), oemID: oemID, oemIDType: nil, country: nil, os: "ios") { result in
            switch result {
            case .success(let payFlowDataRaw):
                try? Utils.writeToPreferences(key: "pay-flow-type", value: payFlowDataRaw.paymentFlow.lowercased())
            case .failure:
                break
            }
        }
    }
    
    func getPayFlow() -> PayFlowType {
        
        if Utils.readFromPreferences(key: "pay-flow-type") == PayFlowType.d2c.rawValue {
            return .d2c
        } else { return .standard }
    }
}
