//
//  IntegratorViewRepresentable.swift
//
//
//  Created by Baluta Eugen on 10.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation
import SwiftUI

struct IntegratorViewRepresentable: UIViewControllerRepresentable {
    var integrator: Integrator
    
    func makeUIViewController(context: Context) -> UIViewController {
        IntegratorViewController(integrator: integrator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // guard let integratorViewController = uiViewController as? IntegratorViewController else { return }
    }
}
