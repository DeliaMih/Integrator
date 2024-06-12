//
//  Integrator + Firebase.swift
//  
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import FirebaseCore
import FirebaseAnalytics

extension Integrator {
    func integrateFirebase() {
        FirebaseApp.configure()
    }
    
    func updateParamPref(value: String) {
        Analytics.setUserProperty("true", forName: "paramPref")
    }
}
