//
//  AttributionService.swift
//
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal protocol AttributionService {
    func getAttribution(bundleID: String, oemID: String?, guestUID: String?, result: @escaping (Result<AttributionRaw, Error>) -> Void)
}
