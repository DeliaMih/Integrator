//
//  Analytical.swift
//
//
//  Created by Baluta Eugen on 13.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import IntegratorClient
import IntegratorDefaults

import AppsFlyerLib
import FirebaseAnalytics

public class AnalyticalClient {
    public init() {}
    
    public func trackEvents(
        productId: String,
        productPrice: Double,
        transactionId: String,
        transactionDate: String,
        locale: String,
        trackingIdentifier: String? = nil,
        path: String? = nil
    ) {
        trackPurchase(transactionId: transactionId)
        
        trackFirebasePurchasePathEvent()
        trackAppsFlyerEvent(
            productId: productId,
            productPrice: productPrice,
            transactionId: transactionId,
            locale: locale
        )
    }
    
    private func trackPurchase(transactionId: String?) {
        IntegratorClient.shared.postPurchase(
            transactionId: transactionId,
            trackingIdentifier: IntegratorDefaults.integrationTrackingID
        )
        // APIClient.deafault.postPurchase(transactionId: transactionId)
    }
    
    private func trackAppsFlyerEvent(
        productId: String,
        productPrice: Double,
        transactionId: String,
        locale: String,
        trackingIdentifier: String? = nil
    ) {
        let currency = Locale(identifier: locale).currencyCode ?? "USD"
        AppsFlyerLib.shared().logEvent(
            name: AFEventPurchase,
            values: [
                AFEventParamContentId: productId,
                AFEventParamPrice: productPrice,
                AFEventParamOrderId: transactionId,
                AFEventParamCurrency: currency,
                AFEventParamContent: trackingIdentifier ?? ""
            ]
        ) { response, error in
            debugPrint(#function, response ?? [:], error?.localizedDescription ?? "")
        }
    }
    
    private func trackFirebasePurchasePathEvent(
        path: String? = nil,
        trackingIdentifier: String? = nil
    ) {
        Analytics.logEvent(
            "PurchaseLocation",
            parameters: [
                "purchaseLocation": path ?? "",
                "deeplink": trackingIdentifier ?? ""
            ].compactMapValues { $0 }
        )
    }
}
