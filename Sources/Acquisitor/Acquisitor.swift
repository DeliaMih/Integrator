//
//  Acquisitor.swift
//
//
//  Created by Baluta Eugen on 12.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import SwiftyStoreKit

import IHProgressHUD

import Analytical
import IntegratorDefaults
import StoreKit

public class Acquisitor {
    enum SubscriptionPeriod: Int {
        case day = 0
        case week = 1
        case month = 2
        case year = 3
    }
    
    public static let shared = Acquisitor()
    public var products: Set<SKProduct> = Set()
    
    private let analytics = AnalyticalClient()
    private var productIdentifiers: [String] = []
    private var subsriptionPerion: SubscriptionPeriod!
    
    public var isAcquired: Bool {
        IntegratorDefaults.isAqcuired
    }
    
    private init() {
        prepareTransactionObserver()
        subsriptionPerion = SubscriptionPeriod(rawValue: IntegratorDefaults.subscriptionPeriod ?? 0)
    }
    
    public func retrieve(products productIds: [String], completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(Set(productIds)) { [weak self] result in
            guard result.error == nil else {
                self?.handleStoreKitError(result.error)
                
                completion(false)
                return
            }
            
            if !result.invalidProductIDs.isEmpty {
                debugPrint("⚠️[WARNING]: Invalid product identifiers |", result.invalidProductIDs)
            }
            
            self?.productIdentifiers = result.retrievedProducts.map { $0.productIdentifier }
            self?.products = result.retrievedProducts
            
            result.retrievedProducts.forEach { product in
                debugPrint("❕Product retrieved:", product.productIdentifier, product.price)
            }
            
            completion(true)
        }
    }
    
    public func acquire(product identifier: String, completion: @escaping (PurchaseDetails?) -> Void) {
        IHProgressHUD.show()
        SwiftyStoreKit.purchaseProduct(identifier) { [weak self] result in
            guard let self else { return }
            switch result {
            case .deferred(let details), .success(let details):
                
                let transaction = PaymentTransactionCodable(
                    productId: identifier,
                    transaction: details.transaction
                )
                transaction.save()
                
                self.analytics.trackEvents(
                    productId: identifier,
                    productPrice: Double(truncating: details.product.price),
                    transactionId: transaction.transactionIdentifier ?? "Unknown",
                    transactionDate: transaction.transactionDate?.toString() ?? "Unknown",
                    locale: details.product.priceLocale.identifier,
                    trackingIdentifier: IntegratorDefaults.integrationTrackingID
                )
                
                if let numberOfUnits = details.product.subscriptionPeriod?.numberOfUnits,
                    let purchasedDate = details.transaction.transactionDate {
                    self.subsriptionPerion = SubscriptionPeriod(rawValue: numberOfUnits) ?? .day
                    print("subsriptionPerion=\(String(describing: self.subsriptionPerion))")
                    
                    let expiredSubscriptionDate = self.getExpiredSubscriptionDate(purchasedDate: purchasedDate)
                    print("expiredSubscriptionDate=\(String(describing: expiredSubscriptionDate))")
                    IntegratorDefaults.expiredDate = expiredSubscriptionDate
                    IntegratorDefaults.subscriptionPeriod = numberOfUnits
                }
                
                IntegratorDefaults.isAqcuired = true
                IntegratorDefaults.boughtProductId = details.productId
                
                completion(details)
            case .error(let error):
                IntegratorDefaults.isAqcuired = false
                IntegratorDefaults.boughtProductId = nil
                completion(nil)
                self.handleStoreKitError(error)
            }
            
            IHProgressHUD.dismiss()
        }
    }
    
    public func restoreAcquisition(for identifier: String, completion: @escaping (RestoreResult) -> Void) {
        validateAndVerifyReciept(identifier: identifier, completion: completion)
    }
}

// Acquisition validation and receipt validation
extension Acquisitor {
    private var sharedSecret: String {
        guard let secret = Bundle.main.object(forInfoDictionaryKey: "RECEIPT_KEYS") as? String else {
            fatalError("Please add RECEIPT_KEYS key in Info.plist")
        }
        
        return secret
    }

    public enum RestoreResult {
        case restored, noPurchases, error
    }
    
    var sandbox: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    private var service: AppleReceiptValidator.VerifyReceiptURLType {
        return sandbox ? .sandbox : .production
    }
    
    private func validateAndVerifyReciept(
        identifier: String,
        completion: @escaping (RestoreResult) -> ()
    ) {
        IHProgressHUD.show(withStatus: "Restoring purchases")

        var receiptValidator = AppleReceiptValidator(
            service: service,
            sharedSecret: sharedSecret
        )
        
        var restoreResult = RestoreResult.noPurchases
        
        SwiftyStoreKit.verifyReceipt(
            using: receiptValidator,
            forceRefresh: false
        ) { [weak self] result in
            guard let self else { return completion(.error) }
            
            switch result {
            case .success(let receipt):
                restoreResult = self.verifySubscription(for: identifier, inReceipt: receipt)
                if !self.isAcquired {
                    restoreResult = self.verifyPurchase(for: identifier, inReceipt: receipt)
                }
                
                IntegratorDefaults.isAqcuired = restoreResult == .restored
                completion(restoreResult)
            case .error(let error):
                IntegratorDefaults.isAqcuired = false
                debugPrint(error.localizedDescription)
                completion(.error)
            }
            
            IHProgressHUD.dismiss()
        }
    }
    
    private func verifySubscription(for identifier: String, inReceipt receipt: ReceiptInfo) -> RestoreResult {
        switch SwiftyStoreKit.verifySubscription(
            ofType: .autoRenewable,
            productId: identifier,
            inReceipt: receipt
        ) {
        case .purchased: return .restored
        default: return .noPurchases
        }
    }
    
    private func verifyPurchase(for identifier: String, inReceipt receipt: ReceiptInfo) -> RestoreResult {
        switch SwiftyStoreKit.verifyPurchase(
            productId: identifier,
            inReceipt: receipt
        ) {
        case .purchased: return .restored
        case .notPurchased: return .noPurchases
        }
    }
}

extension Acquisitor {
    private func prepareTransactionObserver() {
        SwiftyStoreKit.completeTransactions { purchases in
            purchases.forEach { purchase in
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if let transactionDate = purchase.transaction.transactionDate {
                        let expiredSubscriptionDate = self.getExpiredSubscriptionDate(purchasedDate: transactionDate)
                        if IntegratorDefaults.expiredDate < expiredSubscriptionDate {
                            IntegratorDefaults.expiredDate = expiredSubscriptionDate
                            if expiredSubscriptionDate > Date() {
                                IntegratorDefaults.isAqcuired = true
                            }
                        }
                    }
                   
                    guard purchase.needsFinishTransaction else { return }
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                default:
                    break
                }
            }
        }
    }
    
    private func handleStoreKitError(_ error: Error?) {
        guard let error else { return }
        debugPrint(error)
    }
}

extension Acquisitor {
    
    private func getExpiredSubscriptionDate(purchasedDate: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale.current
        
        switch subsriptionPerion {
        case .day:
            return calendar.date(byAdding: .day, value: 1, to: purchasedDate) ?? purchasedDate
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: purchasedDate) ?? purchasedDate
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: purchasedDate) ?? purchasedDate
        case .year:
            return calendar.date(byAdding: .year, value: 1, to: purchasedDate) ?? purchasedDate
        default:
            return calendar.date(byAdding: .day, value: 1, to: purchasedDate) ?? purchasedDate
        }
    }
}
