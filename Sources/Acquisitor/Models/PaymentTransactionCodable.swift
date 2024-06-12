//
//  PaymentTransactionCodable.swift
//
//
//  Created by Baluta Eugen on 12.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import StoreKit

import SwiftyStoreKit
import KeychainSwift

enum PaymentTransactionState: Int, Codable {
    case purchasing
    case purchased
    case failed
    case restored
    case deferred
    
    init(_ state: SKPaymentTransactionState) {
        switch state {
        case .purchasing: self = .purchasing
        case .purchased: self = .purchased
        case .failed: self = .failed
        case .restored: self = .restored
        case .deferred: self = .deferred
        @unknown default: fatalError()
        }
    }
}

public struct PaymentTransactionCodable: Codable {
    var productId: String
    var transactionDate: Date?
    var transactionState: PaymentTransactionState
    var transactionIdentifier: String?
    
    init(
        productId: String,
        transaction: PaymentTransaction
    ) {
        self.productId = productId
        self.transactionDate = transaction.transactionDate
        self.transactionState = PaymentTransactionState(transaction.transactionState)
        self.transactionIdentifier = transaction.transactionIdentifier
    }
    
    func save() {
        let keychain = KeychainSwift()
        
        do {
            var savedTransactions = PaymentTransactionCodable.retrieveTransactions()
            savedTransactions.append(self)
            
            let data = try JSONEncoder().encode(savedTransactions)
            keychain.set(data, forKey: "Acquisitor.Transactions")
        } catch {
            debugPrint("Couldn't save transaction", transactionIdentifier ?? "", productId)
        }
    }
    
    static func retrieveTransactions() -> [PaymentTransactionCodable] {
        let keychain = KeychainSwift()
        do {
            if let transactionsData = keychain.getData("Acquisitor.Transactions") {
                let transactions = try JSONDecoder().decode([PaymentTransactionCodable].self, from: transactionsData)
                return transactions
            }
            
            return []
        } catch {
            debugPrint("Couldn't get saved transaction", error.localizedDescription)
            return []
        }
    }
}
