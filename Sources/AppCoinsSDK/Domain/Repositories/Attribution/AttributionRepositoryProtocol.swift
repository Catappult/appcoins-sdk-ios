//
//  File.swift
//  
//
//  Created by Graciano Caldeira on 12/07/2024.
//

import Foundation

internal protocol AttributionRepositoryProtocol {
    func getAttribution()
    func getGuestUID() -> String
}