//
//  Schema.swift
//  
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation

struct Schema: Decodable {
    enum Role: String, Decodable {
        case editor = "Editor"
        case viewer = "Viewer"
        case none = "None"
    }
    var role: Role
    var name: String
    var schemas: [String]
    
    enum CodingKeys: String, CodingKey {
        case role = "CFBundleTypeRole"
        case name = "CFBundleURLName"
        case schemas = "CFBundleURLSchemes"
    }
}
