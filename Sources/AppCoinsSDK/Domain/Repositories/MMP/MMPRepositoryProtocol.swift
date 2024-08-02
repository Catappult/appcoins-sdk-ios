//
//  AttributionRepositoryProtocol.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal protocol MMPRepositoryProtocol {
    func getAttribution(completion: @escaping () -> Void)
    func getGuestUID() -> String?
    func getOEMID() -> String
}
