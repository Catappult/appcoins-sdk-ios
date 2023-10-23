//
//  AdyenSession.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

internal struct AdyenTransactionSession {
    
    internal let transactionUID: String
    internal let sessionID: String
    internal let sessionData: String
    
    internal init(transactionUID: String, sessionID: String, sessionData: String) {
        self.transactionUID = transactionUID
        self.sessionID = sessionID
        self.sessionData = sessionData
    }
    
    internal init(raw: CreateAdyenTransactionResponseRaw) {
        self.transactionUID = raw.uuid
        self.sessionID = raw.session.sessionID
        self.sessionData = raw.session.sessionData
    }
    
    internal init(raw: TopUpAdyenResponseRaw) {
        self.transactionUID = raw.uuid
        self.sessionID = raw.session.sessionID
        self.sessionData = raw.session.sessionData
    }
}
