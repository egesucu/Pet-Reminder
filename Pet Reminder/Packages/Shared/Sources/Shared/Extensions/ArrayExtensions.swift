//
//  Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Playgrounds

// MARK: - Array
public extension Array {
    static var empty: Self { [] }
}

public extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

public extension Sequence {
    func filter(_ keyPath: KeyPath<Element, Bool>) -> [Element] {
        return self.filter { $0[keyPath: keyPath] }
    }
}

#Playground {
    let _: [AnyObject] = .empty

    let array = [2, 3, 4, 5, 2, 4]
    _ = array.removeDuplicates()
    _ = array[safe: 2]
    _ = array.isNotEmpty

    let custom = [
        (value: 0, active: false),
        (value: 1, active: false),
        (value: 4, active: true),
        (value: 5, active: false)
    ]
    _ = custom.filter(\.active)
}
