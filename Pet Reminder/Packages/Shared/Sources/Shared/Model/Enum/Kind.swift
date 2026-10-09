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
        switch self {
        case .cat:
            let cat = String(localized: SharedStrings.cat)
            Logger.pets.debug("Pet's localized type is: \(cat)")
            return cat
        case .dog:
            let dog = String(localized: SharedStrings.dog)
            Logger.pets.debug("Pet's localized type is: \(dog)")
            return dog
        case .fish:
            let fish = String(localized: SharedStrings.fish)
            Logger.pets.debug("Pet's localized type is: \(fish)")
            return fish
        case .bird:
            let bird = String(localized: SharedStrings.bird)
            Logger.pets.debug("Pet's localized type is: \(bird)")
            return bird
        case .other:
            let other = String(localized: SharedStrings.other)
            Logger.pets.debug("Pet's localized type is: \(other)")
            return other
        }
    }

}
