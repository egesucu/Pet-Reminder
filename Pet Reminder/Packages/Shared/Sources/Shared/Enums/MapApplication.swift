//
//  MapApplication.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public enum MapApplication: String, CaseIterable {
    case google = "Google Maps"
    case apple = "Maps"
    case yandex = "Yandex Maps"
}

extension MapApplication {
    public var name: String {
        self.rawValue
    }
}
