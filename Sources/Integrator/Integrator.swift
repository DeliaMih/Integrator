//
//  Integrator.swift
//  Basic Package for project templates
//
//  Created by Baluta Eugen on 06.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import UIKit
import SwiftUI
import Combine

import Acquisitor
import IntegratorDefaults

import IHProgressHUD

enum IntegratorState {
    case integrated, nonIntegrated
}

enum IntegrationFallbackType {
    case staticFallback, dynamicFallback
}

public class Integrator: NSObject {
    static var main = Integrator()
    
    private var app: UIApplication!
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    private var parent: AnyView!
    
    var isIntegrated = false
    var integratorState: PassthroughSubject<IntegratorState, Never> = .init()
    var cancellables: Set<AnyCancellable> = []
    
    public static func startIntegration(
        with app: UIApplication,
        options launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
        parent: AnyView
    ) {
        main.app = app
        main.launchOptions = launchOptions
        main.parent = parent
        
        main.internalIntegration()
    }
    
    private func internalIntegration() {
        IntegratorDefaults.integrationSessionStart = Date()
        
        listenForState()
        integrateFallback()
        
        UNUserNotificationCenter.current().delegate = self
        
        integrateFirebase()
        integrateAppsFlyer()
        
        Acquisitor.shared.retrieve(products: FirebaseWrapper.shared.products) { _ in }
    }
    
    private func listenForState() {
        integratorState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .integrated:
                    self.app.keyWindow?.rootViewController = UIHostingController(rootView:IntegratorViewRepresentable(integrator: self))
                                                                                    
                                                                                    //self.parent)
                case .nonIntegrated:
                    self.app.keyWindow?.rootViewController = UIHostingController(rootView: self.parent)
                }
            }
            .store(in: &cancellables)
    }
}
