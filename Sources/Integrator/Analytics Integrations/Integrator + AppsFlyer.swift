//
//  Integrator + AppsFlyer.swift
//  
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import UIKit
import AppsFlyerLib

import IntegratorDefaults

extension Integrator {
    func integrateAppsFlyer() {
        guard let key else { fatalError("Please add the APPSFLYER_KEY in the Info.plist") }
        guard let appID else { fatalError("Please add the APP_ID in the Info.plist") }
        
        AppsFlyerLib.shared().appsFlyerDevKey = key
        AppsFlyerLib.shared().appleAppID = appID
        AppsFlyerLib.shared().delegate = self
        #if DEBUG
        // Enable debug mode only for dev builds
        AppsFlyerLib.shared().isDebug = true
        #endif
        
        AppsFlyerLib.shared().start { (dic, error) in
            if let error = error {
                debugPrint("Error: \(#file) \(#line)")
                debugPrint(error)
                return
            }
            if dic != nil {
                return
            }
        }
    }
}

extension Integrator {
    public static func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        AppsFlyerLib.shared().start()
    }
    
    public static func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }
    
    public static func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
}

extension Integrator: AppsFlyerLibDelegate {
    // Handle Conversion Data (Deferred Deep Link)
    public func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        guard let data = data as? [String: Any] else { return }
        integrate(with: data)
    }
    
    public func onConversionDataFail(_ error: Error) {
        integratorState.send(.nonIntegrated)
    }
    
    // Handle Direct Deep Link
    public func onAppOpenAttribution(_ data: [AnyHashable: Any]) {
        if let link = data["link"] { debugPrint("link:", link) }
    }
    public func onAppOpenAttributionFailure(_ error: Error) {
        debugPrint(error)
    }
    
    private func integrate(with data: [String: Any]) {
        guard !IntegratorDefaults.integrationCompromised else {
            removeLocalNotifications()
            integratorState.send(.nonIntegrated)
            return
        }
        
        FirebaseWrapper.shared.updateRemoteConfig { [weak self] in
            guard let self, $0 else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self?.integrate(with: data) }
                return
            }
            
// #if DEBUG
 //           let af_status = true
    //        let af_sub1_str = data["af_sub1"] as? String ?? deeplinkSecondary
//#else
            let af_status = ((data["af_status"] as? String) ?? "") == "Non-organic"
            let af_sub1_str = ((data["af_sub1"] as? String) ?? "")
//#endif
            
            let af_sub1 = af_sub1_str.lowercased() == deeplinkSecondary
            let campaign = data["campaign"] as? String ?? ""
            
            // self.opened = true
            if af_sub1, af_status, FirebaseWrapper.shared.isRomeEnabled {
                IntegratorDefaults.integrationCampaign = campaign
                IntegratorDefaults.integrationTrackingID = [af_sub1_str, campaign].filter({ !$0.isEmpty }).joined(separator: " ")

                self.localNotificationsStatus { [weak self] status in
                    if status == .authorized {
                        if !UserDefaults.standard.bool(forKey: "Notifications") {
                            self?.setupLocalNotifications()
                        }
                    } else {
                        self?.localNotificationsRegister { [weak self] state in
                            self?.setupLocalNotifications()
                        }
                    }
                }

                if IntegratorDefaults.isAqcuired {
                    self.removeLocalNotifications()
                }
                
                self.integratorState.send(.integrated)
            } else {
                self.removeLocalNotifications()
                self.integratorState.send(.nonIntegrated)
            }
        }
    }
}
