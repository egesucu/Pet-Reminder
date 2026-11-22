//
//  Kind.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 22.09.2024.
//  Copyright © 2024 Ege Sucu. All rights reserved.
//

import Foundation
import OSLog

public enum Kind: String, Sendable {
    case cat, dog, fish, bird, other
}

extension Kind: CaseIterable, Codable, Equatable {}

extension Kind {
    public var localizedName: String {
        return switch self {
        case .cat:
            String(localized: SharedStrings.cat)
        case .dog:
            String(localized: SharedStrings.dog)
        case .fish:
            String(localized: SharedStrings.fish)
        case .bird:
            String(localized: SharedStrings.bird)
        case .other:
            String(localized: SharedStrings.other)
        }
    }
}
