//
//  Bool.swift
//
//
//  Created by Baluta Eugen on 12.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation

extension Bool {
    var int: Int {
        return self ? 1 : 0
    }
    
    var intValue: String {
        return self ? "1" : "0"
    }
}
