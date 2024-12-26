//
//  AuthState.swift
//
//
//  Created by Graciano Caldeira on 16/12/2024.
//

import Foundation

internal enum AuthState {
    case choice
    case google
    case magicLink
    case loading
    case success
    case error
}
