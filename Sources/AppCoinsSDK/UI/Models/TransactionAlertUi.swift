//
//  TransactionAlertUi.swift
//
//
//  Created by aptoide on 07/03/2023.
//

import Foundation

internal protocol TransactionAlertRepresentable {
    var domain: String? { get }
    var description: String? { get }
    var sku: String? { get }
    var moneyAmount: Double { get }
    var moneyCurrency: Currency { get }
    var paymentMethods: [PaymentMethod] { get }
}

internal enum TransactionUI {
    case regular(TransactionAlertUI)
    case direct(DirectTransactionAlertUI)
}

extension TransactionUI {
    var common: TransactionAlertRepresentable {
        switch self {
        case .regular(let UI):
            return UI
        case .direct(let UI):
            return UI
        }
    }
    
    internal func getTitle() -> String {
        return common.description ?? ""
    }
}

internal struct TransactionAlertUI {
    
    internal let domain: String?
    internal let description: String?
    internal let category: TransactionCategory?
    internal let sku: String?
    internal let moneyAmount: Double
    internal let moneyCurrency: Currency
    internal let appcAmount: Double
    internal let bonusAmount: Double
    internal let bonusCurrency: Currency
    internal let balanceAmount: Double
    internal let balanceCurrency: Currency
    internal var paymentMethods: [PaymentMethod]
}

extension TransactionAlertUI: TransactionAlertRepresentable {}

internal struct DirectTransactionAlertUI {
    
    internal let domain: String?
    internal let description: String?
    internal let sku: String?
    internal let moneyAmount: Double
    internal let moneyCurrency: Currency
    internal var paymentMethods: [PaymentMethod]
}

extension DirectTransactionAlertUI: TransactionAlertRepresentable {}
