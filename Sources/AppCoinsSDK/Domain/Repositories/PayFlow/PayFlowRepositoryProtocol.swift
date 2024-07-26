//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 25/07/2024.
//

import Foundation

internal protocol PayFlowRepositoryProtocol {
    func setPayFlow()
    func getPayFlow() -> PayFlowType
}
