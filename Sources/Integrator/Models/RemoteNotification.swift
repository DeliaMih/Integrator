//
//  RemoteNotification.swift
//
//
//  Created by Baluta Eugen on 08.11.2023.
//  All rights reserved to Midnight.Works
//

import Foundation

struct RemoteNotification: Decodable {
    var time: Double = 0.0
    var title: String = ""
    var subtitle: String = ""
    var body: String = ""
}
