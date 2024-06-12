//
//  UIApplication.swift
//  
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import UIKit

extension UIApplication {
    public var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }
    }
    
    public static var applicationVersion: String {
      return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}
