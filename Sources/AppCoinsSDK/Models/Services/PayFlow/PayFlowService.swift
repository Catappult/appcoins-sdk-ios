//
//  PayFlowService.swift
//  
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal protocol PayFlowService {
    func setPayFlow(package: String, packageVercode: String, sdkVercode: Int, locale: String?, oemID: String?, oemIDType: String?, country: String?, os: String, result: @escaping (Result<PayFlowDataRaw, PayFlowError>) -> Void)
}
