//
//  PayFlowRepository.swift
//
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal class PayFlowRepository: PayFlowRepositoryProtocol {
    
    private let PayFlowService: PayFlowService = PayFlowClient()
    private let mmpRepository: MMPRepositoryProtocol
    
    internal init(repository: MMPRepositoryProtocol = MMPRepository()) {
        self.mmpRepository = repository
    }
    
    internal func setPayFlow() {
        self.PayFlowService.setPayFlow(package: BuildConfiguration.packageName, packageVercode: BuildConfiguration.packageVersion, sdkVercode: BuildConfiguration.vercode, locale: Locale.current.regionCode?.lowercased(), oemID: mmpRepository.getOEMID(), oemIDType: nil, country: nil, os: "ios") { result in
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
