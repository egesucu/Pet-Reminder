//
//  Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
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

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

extension Sequence {
    func filter(_ keyPath: KeyPath<Element, Bool>) -> [Element] {
        return self.filter { $0[keyPath: keyPath] }
    }
}
