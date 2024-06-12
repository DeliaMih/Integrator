//
//  String.swift
//  
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation

extension String {
    public var withoutDot: String {
        replacingOccurrences(of: ".", with: "")
    }
    
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}
