//
//  FirebaseWrapper.swift
//
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import UIKit
import FirebaseRemoteConfig

fileprivate enum FirebaseRemoteConfigKey: String, CaseIterable {
    case analytics = "analyticsLink"
    case dynamicProducts
    case secondDynamicProducts = "dynamicProducts2"
    case rome = "enableRoma"
    case sub = "enableSub"
    case introProduct
    case domain = "mainDomain"
    case notifications
    case policies = "policiesDomain"
    case receipt = "receiptValidationLink"
    
    var defaultValue: Any? {
        switch self {
        case .analytics: return ""
        case .dynamicProducts: return []
        case .secondDynamicProducts: return []
        case .rome: return false
        case .sub: return false
        case .introProduct: return ""
        case .domain: return ""
        case .notifications: return nil
        case .policies: return ""
        case .receipt: return ""
        }
    }
}

public class FirebaseWrapper {
    public static var shared = FirebaseWrapper()
    
    private var config: RemoteConfig
    
    private init() {
        self.config = RemoteConfig.remoteConfig()
        
        loadDefaultValues()
    }
    
    // MARK: Remote Config Properties
    var isRomeEnabled: Bool {
        config[FirebaseRemoteConfigKey.rome.rawValue].boolValue
    }
    
    var isSubEnabled: Bool {
        config[FirebaseRemoteConfigKey.sub.rawValue].boolValue
    }
    
    var mainDomain: String {
        (config[FirebaseRemoteConfigKey.domain.rawValue].stringValue) ?? (FirebaseRemoteConfigKey.domain.defaultValue as! String)
    }
    
    var validation: String {
        (config[FirebaseRemoteConfigKey.receipt.rawValue].stringValue) ?? (FirebaseRemoteConfigKey.receipt.defaultValue as! String)
    }
    
    var analytics: String {
        (config[FirebaseRemoteConfigKey.analytics.rawValue].stringValue) ?? (FirebaseRemoteConfigKey.analytics.defaultValue as! String)
    }
    
    var policies: String {
        (config[FirebaseRemoteConfigKey.policies.rawValue].stringValue) ?? (FirebaseRemoteConfigKey.policies.defaultValue as! String)
    }
    
    var notifications: [RemoteNotification] {
        let notificationsData = config[FirebaseRemoteConfigKey.notifications.rawValue].dataValue
        
        let decoded = try? JSONDecoder().decode([RemoteNotification].self, from: notificationsData)
        return decoded ?? []
    }
    
    var introProduct: String {
        (config[FirebaseRemoteConfigKey.introProduct.rawValue].stringValue) ?? (FirebaseRemoteConfigKey.introProduct.defaultValue as! String)
    }
    
    public var products: [String] {
        guard let data = config[
            FirebaseRemoteConfigKey.dynamicProducts.rawValue
        ].jsonValue as? [String] else {
            return []
        }
        
        return data
    }
}

// MARK: - Default Values
extension FirebaseWrapper {
    func loadDefaultValues() {
        let defaults = FirebaseRemoteConfigKey.allCases.reduce(into: [String: NSObject]()) {
            $0[$1.rawValue] = $1.defaultValue as? NSObject
        }
        
        RemoteConfig.remoteConfig().setDefaults(defaults)
    }
}

// MARK: Remote Config Fetch
extension FirebaseWrapper {
    func updateRemoteConfig(completion: @escaping (Bool) -> Void) {
        config.fetchAndActivate { [weak self] status, error in
            switch status {
            case .error:
                self?.handle(error: error)
                completion(false)
            default:
                completion(true)
            }
        }
    }
}

// MARK: Wrapper error debug
private extension FirebaseWrapper {
    private func handle(
        error: Error?,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        debugPrint("Error:", file, function, line)
        if let error { debugPrint(error) } else { debugPrint(function, "failed without error") }
    }
}
