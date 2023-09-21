//
//  File.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import Foundation

struct AdyenTransactionSession {
    
    let transactionUID: String
    let sessionID: String
    let sessionData: String
    
    init(transactionUID: String, sessionID: String, sessionData: String) {
        self.transactionUID = transactionUID
        self.sessionID = sessionID
        self.sessionData = sessionData
    }
    
    init(raw: CreateAdyenTransactionResponseRaw) {
        self.transactionUID = raw.uuid
        self.sessionID = raw.session.sessionID
        self.sessionData = raw.session.sessionData
    }
    
    init(raw: TopUpAdyenResponseRaw) {
        self.transactionUID = raw.uuid
        self.sessionID = raw.session.sessionID
        self.sessionData = raw.session.sessionData
    }
}
