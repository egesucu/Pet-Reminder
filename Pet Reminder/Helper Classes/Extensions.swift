//
//  Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

// MARK: - Array
extension Array {
    static var empty: Self { [] }
}

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Pet
extension Pet {
    var selection: NotificationSelection {
        get {
            return NotificationSelection(rawValue: self.choice) ?? .both
        }
        set {
            choice = newValue.rawValue
        }
    }
}
