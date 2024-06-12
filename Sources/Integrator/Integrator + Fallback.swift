//
//  Integrator + Fallback.swift
//
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import UIKit

import IntegratorDefaults

extension Integrator {
    func integrateFallback() {
        NotificationCenter.default
            .publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .sink() { [weak self] _ in self?.fallback(type: .staticFallback) }
            .store(in: &cancellables)
        
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)
    }
    
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) { if keyPath == "captured", UIScreen.main.isCaptured { fallback(type: .dynamicFallback) } }
    
    private func fallback(type: IntegrationFallbackType) {
        IntegratorDefaults.integrationCompromised = true
        
        switch type {
        case .staticFallback:
            debugPrint("Took a screenshot")
        case .dynamicFallback:
            debugPrint("User is recording")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { debugPrint(Int("")!) }
    }
}
