//
//  ExternalPurchaseServiceRepository.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/01/2026.
//

import Foundation
import MarketplaceKit
import SwiftData
import SwiftUI

@available(iOS 26, *)
internal class ExternalPurchaseServiceRepository: ExternalPurchaseServiceRepositoryProtocol {
    
    private let sdkService: SDKService = SDKServiceClient()
    private let externalPurchaseTokenDatabaseService: ExternalPurchaseTokenDatabaseService
    
    internal init(context: ModelContext) {
        self.externalPurchaseTokenDatabaseService = ExternalPurchaseTokenDatabaseClient(context: context)
    }
    
    internal func reportToken() {
        // Always try to flush first
        self.flushReports()
        
        self.generateToken { result in
            switch result {
            case .success(let token):
                // Store token locally
                var storedToken: ExternalPurchaseTokenModel? = self.externalPurchaseTokenDatabaseService.add(
                    appAppleId: token.appAppleId,
                    bundleId: token.bundleId,
                    tokenCreationDate: token.tokenCreationDate,
                    externalPurchaseId: token.externalPurchaseId,
                    tokenType: token.tokenType,
                    transactionUID: nil
                )
                
                // Record token on service
                self.sdkService.record(body: RecordTokenRaw.fromParameters(token: token)) { result in
                    switch result {
                    case .success(_):
                        Utils.log("Reported External Purchase Token: \(token) successfully")
                        
                        if let storedToken = storedToken {
                            self.externalPurchaseTokenDatabaseService.markTokenReported(storedToken)
                        }
                    case .failure(_):
                        // Take no action when token can't be recorded – we'll try to flush it later
                        return
                    }
                }
            case .failure(let failure):
                // Take no action when token can't be generated
                return
            }
        }
    }
    
    internal func associateTransaction(transactionUID: String) {
        // Always try to flush first
        self.flushReports()
        
        var storedToken: ExternalPurchaseTokenModel? = self.externalPurchaseTokenDatabaseService.latestToken()
        
        if let storedToken = storedToken, !storedToken.hasReportedTransaction {
            let token = ExternalPurchaseToken(
                appAppleId: storedToken.appAppleId,
                bundleId: storedToken.bundleId,
                tokenCreationDate: storedToken.tokenCreationDate,
                externalPurchaseId: storedToken.externalPurchaseId,
                tokenType: storedToken.tokenType
            )
            
            self.externalPurchaseTokenDatabaseService.associateTransaction(storedToken, transactionUID: transactionUID)
            
            self.sdkService.record(body: RecordTokenRaw.fromParameters(token: token, transactionUID: transactionUID)) {
                result in
                
                switch result {
                case .success(_):
                    Utils.log("Reported External Purchase Token: \(token) with associated Transaction ID: \(transactionUID) successfully")
                    
                    self.externalPurchaseTokenDatabaseService.markTransactionReported(storedToken)
                case .failure(_):
                    // Take no action when token can't be recorded – we'll try to flush it later
                    return
                }
            }
        } else {
            self.generateToken { result in
                switch result {
                case .success(let token):
                    // Store token locally
                    var storedToken: ExternalPurchaseTokenModel? = self.externalPurchaseTokenDatabaseService.add(
                        appAppleId: token.appAppleId,
                        bundleId: token.bundleId,
                        tokenCreationDate: token.tokenCreationDate,
                        externalPurchaseId: token.externalPurchaseId,
                        tokenType: token.tokenType,
                        transactionUID: transactionUID
                    )
                    
                    // Record token on service
                    self.sdkService.record(body: RecordTokenRaw.fromParameters(token: token, transactionUID: transactionUID)) { result in
                        switch result {
                        case .success(_):
                            Utils.log("Reported External Purchase Token: \(token) with associated Transaction ID: \(transactionUID) successfully")
                            
                            if let storedToken = storedToken {
                                self.externalPurchaseTokenDatabaseService.markTokenReported(storedToken)
                                self.externalPurchaseTokenDatabaseService.markTransactionReported(storedToken)
                            }
                        case .failure(_):
                            // Take no action when token can't be recorded – we'll try to flush it later
                            return
                        }
                    }
                case .failure(let failure):
                    // Take no action when token can't be generated
                    return
                }
            }
        }
    }
    
    internal func flushReports() {
        Utils.log("Attempting to flush External Purchase Reports")
        
        for unreportedTokenRaw in self.externalPurchaseTokenDatabaseService.getUnreportedTokens() {
            let unreportedToken: ExternalPurchaseToken = ExternalPurchaseToken(
                appAppleId: unreportedTokenRaw.appAppleId,
                bundleId: unreportedTokenRaw.bundleId,
                tokenCreationDate: unreportedTokenRaw.tokenCreationDate,
                externalPurchaseId: unreportedTokenRaw.externalPurchaseId,
                tokenType: unreportedTokenRaw.tokenType
            )
            Utils.log("Flushing External Purchase Token: \(unreportedToken)")
            self.sdkService.record(body: RecordTokenRaw.fromParameters(token: unreportedToken)) { result in
                switch result {
                case .success(_):
                    Utils.log("Reported External Purchase Token: \(unreportedToken) successfully")
                    self.externalPurchaseTokenDatabaseService.markTokenReported(unreportedTokenRaw)
                case .failure(_):
                    // Take no action when token can't be recorded – we'll try to flush it later
                    return
                }
            }
        }
        
        for unreportedTransactionRaw in self.externalPurchaseTokenDatabaseService.getUnreportedTransactions() {
            let unreportedTransactionToken: ExternalPurchaseToken = ExternalPurchaseToken(
                appAppleId: unreportedTransactionRaw.appAppleId,
                bundleId: unreportedTransactionRaw.bundleId,
                tokenCreationDate: unreportedTransactionRaw.tokenCreationDate,
                externalPurchaseId: unreportedTransactionRaw.externalPurchaseId,
                tokenType: unreportedTransactionRaw.tokenType
            )
            Utils.log("Flushing External Purchase Token: \(unreportedTransactionToken) with associated Transaction ID: \(unreportedTransactionRaw.transactionUID)")
            self.sdkService.record(body: RecordTokenRaw.fromParameters(token: unreportedTransactionToken, transactionUID: unreportedTransactionRaw.transactionUID)) { result in
                switch result {
                case .success(_):
                    Utils.log("Reported External Purchase Token: \(unreportedTransactionToken) with associated Transaction ID: \(unreportedTransactionRaw.transactionUID) successfully")
                    self.externalPurchaseTokenDatabaseService.markTokenReported(unreportedTransactionRaw)
                case .failure(_):
                    // Take no action when token can't be recorded – we'll try to flush it later
                    return
                }
            }
        }
    }
    
    private func generateToken(completion: @escaping (Result<ExternalPurchaseToken, SDKServiceError>) -> Void) {
        Task { @MainActor in
            do {
                let rawToken = try await TransactionReporting.token(for: .coreTechnology)
                let token = try decodeBase64URL(rawToken, as: ExternalPurchaseToken.self)
                Utils.log("Generated External Purchase Token: \(token)")
                completion(.success(token))
            } catch let error as MarketplaceKitError {
                Utils.log("Error generating External Purchase Token: \(error.localizedDescription) at generateToken:ExternalPurchaseServiceRepository.swift")
                completion(.failure(
                    SDKServiceError.failed(
                        message: "MarketplaceKit Error",
                        description: "MarketplaceKit error: \(error.localizedDescription) at generateToken:ExternalPurchaseServiceRepository.swift"
                    )
                ))
            } catch {
                Utils.log("Error generating External Purchase Token: \(error.localizedDescription) at generateToken:ExternalPurchaseServiceRepository.swift")
                completion(.failure(
                    SDKServiceError.failed(
                        message: "Unknown Error",
                        description: "Unknown error: \(error.localizedDescription) at generateToken:ExternalPurchaseServiceRepository.swift"
                    )
                ))
            }
        }
    }
    
    private func decodeBase64URL<T: Decodable>(_ value: String, as type: T.Type) throws -> T {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64) else {
            throw NSError(domain: "Base64URL", code: 0)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
