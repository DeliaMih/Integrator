//
//  Integrator + Configuration.swift
//
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation

// MARK: Integrator Configurations
extension Integrator {
    var key: String? {
        Bundle.main.object(forInfoDictionaryKey: "APPSFLYER_KEY") as? String
    }
    
    var appID: String? {
        Bundle.main.object(forInfoDictionaryKey: "APP_ID") as? String
    }
    
    var schemas: [Schema] {
        guard let jsonSchemas = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]],
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonSchemas),
              let schemas = try? JSONDecoder().decode([Schema].self, from: jsonData) else {
            return []
        }
        return schemas
    }
    
    var deeplink: String {
        guard let schema = schemas.first(where: { $0.name == "deeplink" })?.schemas.first else {
            fatalError("Please add the deeplink in URL Types in Info.plist")
        }
        
        return schema
    }
    
    var deeplinkSecondary: String {
        guard let schema = schemas.first(where: { $0.name == "deeplinkSecondary" })?.schemas.first else {
            fatalError("Please add the deeplinkSecondary in URL Types in Info.plist")
        }
        
        return schema
    }
}
