//
//  IntegratorViewController.swift
//
//
//  Created by Baluta Eugen on 10.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import SwiftUI
import UIKit
import WebKit

import IHProgressHUD
import Acquisitor
import IntegratorDefaults

class IntegratorViewController: UIViewController {
    private var integrator: Integrator!
    
    private lazy var web: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    init(integrator: Integrator) {
        self.integrator = integrator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(web)
        web.navigationDelegate = self
        
        setWebConstraints()
        handleUrl(started: false)
    }
    
    func startAcquisition(for identifier: String) {
        Acquisitor.shared.acquire(product: identifier) { [weak self] details in
            guard details != nil else {
                IHProgressHUD.dismiss()
                return
            }
            
            self?.handleUrl(started: true)
        }
    }
}

extension IntegratorViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.request.url?.absoluteString.contains("/buy") ?? false {
            if FirebaseWrapper.shared.isSubEnabled,
               let randomProduct = FirebaseWrapper.shared.products.randomElement() {
                startAcquisition(for: randomProduct)
            } else {
                startAcquisition(for: FirebaseWrapper.shared.introProduct)
            }
            
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.request.url?.absoluteString.contains("/close") ?? false {
            integrator.removeLocalNotifications()
            integrator.integratorState.send(.nonIntegrated)
        }
        
        if navigationAction.navigationType == .linkActivated {
            if FirebaseWrapper.shared.isSubEnabled,
               let randomProduct = FirebaseWrapper.shared.products.randomElement() {
                startAcquisition(for: randomProduct)
            } else {
                startAcquisition(for: FirebaseWrapper.shared.introProduct)
            }
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(
        webView: WKWebView!,
        createWebViewWithConfiguration configuration: WKWebViewConfiguration!,
        forNavigationAction navigationAction: WKNavigationAction!,
        windowFeatures: WKWindowFeatures!
    ) -> WKWebView! {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
        return nil
    }
    
    func webView(
        _ webView: WKWebView,
        didCommit navigation: WKNavigation!
    ) {
        
    }
}

extension IntegratorViewController {
    private func handleUrl(started: Bool) {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = FirebaseWrapper.shared.mainDomain
        components.path = "/bv/"
        
        var query: [URLQueryItem] = [
            URLQueryItem(name: "started", value: started.intValue),
            URLQueryItem(name: "osinfo", value: UIDevice.current.systemVersion.urlEncoded),
            URLQueryItem(name: "name", value: UIDevice.current.name.urlEncoded),
            URLQueryItem(name: "device_id", value: (UIDevice.current.identifierForVendor?.uuidString ?? "").uppercased().urlEncoded),
            URLQueryItem(name: "lang", value: String(Locale.preferredLanguages[0].split(separator: "-").first ?? "en"))
        ]
        
        components.percentEncodedQueryItems = query
        
        defer {
            if let url = components.url {
                web.load(URLRequest(url: url))
            } else {
                web.load(URLRequest(url: URL(string: "https://\(FirebaseWrapper.shared.mainDomain)/bv/?started=\(started.int)")!))
            }
        }
        
        if var camp = IntegratorDefaults.integrationCampaign {
            camp = camp.replacingOccurrences(of: "{", with: "")
            camp = camp.replacingOccurrences(of: "}", with: "")
            if !camp.isEmpty {
                query.append(URLQueryItem(name: "camp", value: camp.urlEncoded))
                components.percentEncodedQueryItems = query
            }
        }
        return
    }
    
    private func setWebConstraints() {
        web.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: web, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: web, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: web, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: web, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0).isActive = true
    }
}

extension IntegratorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension WKWebView {
    override open var safeAreaInsets: UIEdgeInsets { return .zero }
}

extension WKWebView {
    func setScrollEnabled(enabled: Bool) {
        scrollView.isScrollEnabled = enabled
        scrollView.panGestureRecognizer.isEnabled = enabled
        scrollView.bounces = enabled
        
        subviews.forEach { subview in
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = enabled
                subview.bounces = enabled
                subview.panGestureRecognizer.isEnabled = enabled
            }
            
            subview.subviews.forEach { subScrollView in
                if type(of: subScrollView) == NSClassFromString("WKContentView")! {
                    subScrollView.gestureRecognizers?.forEach { gesture in
                        subScrollView.removeGestureRecognizer(gesture)
                    }
                }
            }
        }
    }
}
