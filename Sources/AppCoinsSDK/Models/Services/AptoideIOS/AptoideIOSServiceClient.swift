//
//  AptoideIOSServiceClient.swift
//
//
//  Created by aptoide on 18/05/2023.
//

import Foundation

internal class AptoideIOSServiceClient : AptoideIOSService {

    private let endpoint: String
    
    internal init(endpoint: String = BuildConfiguration.aptoideIosServiceURL) {
        self.endpoint = endpoint
    }
    
}
