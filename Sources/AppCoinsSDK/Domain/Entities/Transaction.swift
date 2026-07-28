//
//  Transaction.swift
//
//
//  Created by aptoide on 15/05/2023.
//

import Foundation
@_implementationOnly import StoreKit

public struct Transaction: Codable {

    public enum RevocationReason: String, Codable, Equatable, Hashable {
        case other
        case developerIssue
    }

    public enum OwnershipType: String, Codable, Equatable, Hashable {
        case purchased
        case familyShared
    }

    public let id: String
    public let productID: String
    public let purchaseDate: Date
    public let appAccountToken: UUID?
    // Not available from the AppCoins API — always nil
    public let revocationDate: Date?
    // Not available from the AppCoins API — always nil
    public let revocationReason: RevocationReason?
    // AppCoins does not support Family Sharing — always .purchased
    public let ownershipType: OwnershipType

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    internal init(raw: PurchaseRaw) {
        self.id = raw.uid
        self.productID = raw.sku
        self.purchaseDate = Transaction.dateFormatter.date(from: raw.created) ?? Date()
        self.appAccountToken = raw.payload.flatMap { UUID(uuidString: $0) }
        self.revocationDate = nil
        self.revocationReason = nil
        self.ownershipType = .purchased
    }

    // MARK: - Public static queries

    public static var all: AsyncStream<VerificationResult<Transaction>> {
        let domain = Bundle.main.bundleIdentifier ?? ""
        return AsyncStream { continuation in
            Task {
                await withCheckedContinuation { inner in
                    WalletUseCases.shared.getWalletList { walletList in
                        let group = DispatchGroup()
                        var list: [Transaction] = []
                        for wallet in walletList {
                            group.enter()
                            TransactionUseCases.shared.getAllTransactions(domain: domain, wa: wallet) { result in
                                if case .success(let transactions) = result { list += transactions }
                                group.leave()
                            }
                        }
                        group.notify(queue: .main) {
                            for t in list.sorted(by: { $0.purchaseDate > $1.purchaseDate }) {
                                continuation.yield(.verified(t))
                            }
                            continuation.finish()
                            inner.resume()
                        }
                    }
                }
            }
        }
    }

    public static var currentEntitlements: AsyncStream<VerificationResult<Transaction>> {
        return unfinished
    }

    private static var updatesContinuation: AsyncStream<VerificationResult<Transaction>>.Continuation?
    private static let updatesStream: AsyncStream<VerificationResult<Transaction>> = {
        AsyncStream { continuation in updatesContinuation = continuation }
    }()

    public static var updates: AsyncStream<VerificationResult<Transaction>> {
        return updatesStream
    }

    internal static func send(_ result: VerificationResult<Transaction>) {
        updatesContinuation?.yield(result)
    }

    public static var unfinished: AsyncStream<VerificationResult<Transaction>> {
        let domain = Bundle.main.bundleIdentifier ?? ""
        return AsyncStream { continuation in
            Task {
                await withCheckedContinuation { inner in
                    WalletUseCases.shared.getWalletList { walletList in
                        let group = DispatchGroup()
                        var list: [Transaction] = []
                        for wallet in walletList {
                            group.enter()
                            TransactionUseCases.shared.getTransactionsByState(
                                domain: domain,
                                state: ["PENDING", "ACKNOWLEDGED"],
                                wa: wallet
                            ) { result in
                                if case .success(let transactions) = result { list += transactions }
                                group.leave()
                            }
                        }
                        group.notify(queue: .main) {
                            for t in list.sorted(by: { $0.purchaseDate > $1.purchaseDate }) {
                                continuation.yield(.verified(t))
                            }
                            continuation.finish()
                            inner.resume()
                        }
                    }
                }
            }
        }
    }

    public static func latest(for productID: String) async -> VerificationResult<Transaction>? {
        let domain = Bundle.main.bundleIdentifier ?? ""
        return await withCheckedContinuation { continuation in
            WalletUseCases.shared.getWalletList { walletList in
                let group = DispatchGroup()
                var list: [Transaction] = []
                for wallet in walletList {
                    group.enter()
                    TransactionUseCases.shared.getLatestTransaction(domain: domain, sku: productID, wa: wallet) { result in
                        if case .success(let t) = result, let t = t { list.append(t) }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    let latest = list.sorted(by: { $0.purchaseDate > $1.purchaseDate }).first
                    continuation.resume(returning: latest.map { .verified($0) })
                }
            }
        }
    }

    // MARK: - Instance methods

    public func finish() async {
        let domain = Bundle.main.bundleIdentifier ?? ""
        Utils.log("Transaction.finish() at Transaction.swift", category: "Lifecycle", level: .default)

        await withCheckedContinuation { continuation in
            WalletUseCases.shared.getWalletList { walletList in
                let group = DispatchGroup()
                var isConsumed = false
                for wallet in walletList {
                    group.enter()
                    TransactionUseCases.shared.consumeTransaction(
                        domain: domain,
                        uid: self.id,
                        wa: wallet
                    ) { result in
                        if case .success = result { isConsumed = true }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    if !isConsumed {
                        Utils.log("Transaction could not be consumed at Transaction.swift:finish", level: .error)
                    }
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Internal

    internal static func verify(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        purchaseUID: String,
        completion: @escaping (Result<Transaction, AppCoinsSDKError>) -> Void
    ) {
        Utils.log(
            "Transaction.verify(domain: \(domain), purchaseUID: \(purchaseUID)) at Transaction.swift",
            category: "Lifecycle",
            level: .default
        )

        WalletUseCases.shared.getWalletList { walletList in
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "verify-queue", attributes: .concurrent)
            var isVerified = false
            var verifiedTransaction: Transaction?
            var error: AppCoinsSDKError?

            for wallet in walletList {
                group.enter()
                queue.async {
                    TransactionUseCases.shared.verifyTransaction(
                        domain: domain,
                        uid: purchaseUID,
                        wa: wallet
                    ) { result in
                        switch result {
                        case .success(let transaction):
                            isVerified = true
                            verifiedTransaction = transaction
                        case .failure(let failure):
                            if wallet.getWalletAddress() == walletList.last?.getWalletAddress() {
                                switch failure {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(message: message, description: description, request: request)
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(message: message, description: description, request: request)
                                case .purchaseVerificationFailed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(message: message, description: description, request: request)
                                }
                            }
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                if isVerified, let t = verifiedTransaction {
                    Utils.log("Transaction \(purchaseUID) verified at Transaction.swift:verify")
                    completion(.success(t))
                } else if let error = error {
                    Utils.log("Verification failed: \(error) at Transaction.swift:verify", level: .error)
                    completion(.failure(error))
                } else {
                    Utils.log("Verification failed with unknown error at Transaction.swift:verify", level: .error)
                    completion(.failure(AppCoinsSDKError.unknown(
                        message: "Failed to verify transaction",
                        description: "The transaction was not verified at Transaction.swift:verify"
                    )))
                }
            }
        }
    }

    internal func acknowledge(
        domain: String = (Bundle.main.bundleIdentifier ?? ""),
        completion: @escaping (AppCoinsSDKError?) -> Void
    ) {
        Utils.log("Transaction.acknowledge(domain: \(domain)) at Transaction.swift", category: "Lifecycle", level: .default)

        WalletUseCases.shared.getWalletList { walletList in
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "acknowledge-queue", attributes: .concurrent)
            var isAcknowledged = false
            var error: AppCoinsSDKError?

            for wallet in walletList {
                group.enter()
                queue.async {
                    TransactionUseCases.shared.acknowledgeTransaction(
                        domain: domain,
                        uid: self.id,
                        wa: wallet
                    ) { result in
                        switch result {
                        case .success:
                            isAcknowledged = true
                        case .failure(let failure):
                            if wallet.getWalletAddress() == walletList.last?.getWalletAddress() {
                                switch failure {
                                case .failed(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(message: message, description: description, request: request)
                                case .noInternet(let message, let description, let request):
                                    error = AppCoinsSDKError.networkError(message: message, description: description, request: request)
                                case .general(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(message: message, description: description, request: request)
                                case .noBillingAgreement(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(message: message, description: description, request: request)
                                case .timeOut(let message, let description, let request):
                                    error = AppCoinsSDKError.systemError(message: message, description: description, request: request)
                                }
                            }
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                if isAcknowledged {
                    Utils.log("Transaction acknowledged at Transaction.swift:acknowledge")
                    completion(nil)
                } else if let error = error {
                    Utils.log("Transaction could not be acknowledged: \(error) at Transaction.swift:acknowledge", level: .error)
                    completion(error)
                } else {
                    Utils.log("Transaction could not be acknowledged (unknown error) at Transaction.swift:acknowledge", level: .error)
                    completion(AppCoinsSDKError.unknown(
                        message: "Failed to acknowledge transaction",
                        description: "The transaction was not acknowledged at Transaction.swift:acknowledge"
                    ))
                }
            }
        }
    }
}
