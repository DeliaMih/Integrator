//
//  Date.swift
//
//
//  Created by Baluta Eugen on 13.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation

extension Date {
    func string(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func toString(dateFormat format: String? = "yyyy-MM-dd HH:mm:ssZ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
