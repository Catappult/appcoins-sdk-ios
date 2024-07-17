//
//  AttributionService.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal protocol MMPService {
    func getAttribution(bundleID: String, result: @escaping (Result<AttributionRaw, Error>) -> Void)
}
