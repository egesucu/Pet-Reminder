//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 3.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import Foundation

// MARK: - Pet
extension Pet {
    var selection: FeedTimeSelection {
        get {
            return FeedTimeSelection(rawValue: self.choice) ?? .both
        }
        set {
            choice = newValue.rawValue
        }
    }
}
