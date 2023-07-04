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
