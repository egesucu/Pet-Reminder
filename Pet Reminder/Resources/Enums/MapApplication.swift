//
//  MapApplication.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum MapApplication: String, CaseIterable {
    case google = "Google Maps"
    case apple = "Maps"
    case yandex = "Yandex Maps"
}

extension MapApplication {
    var name: String {
        self.rawValue
    }
}
