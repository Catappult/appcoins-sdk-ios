//
//  SDKService.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation

@available(iOS 26.0, *)
internal protocol SDKService {
    
    func record(body: RecordTokenRaw, result: @escaping (Result<Bool, SDKServiceError>) -> Void)
    
}
