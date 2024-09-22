//
//  PetType.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 22.09.2024.
//  Copyright © 2024 Ege Sucu. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

enum PetType {
    case cat, dog, fish, bird, other
}

extension PetType: CaseIterable {}

extension PetType: Codable {}

extension PetType {
    var name: String {
        return switch self {
        case .cat: String(localized: "Cat")
        case .dog: String(localized: "Dog")
        case .fish: String(localized: "Fish")
        case .bird: String(localized: "Bird")
        case .other: String(localized: "Other")
        }
    }
    
    var image: Image {
        return switch self {
        case .cat:
            Image(.defaultCat)
                .resizable()
        case .dog:
            Image(.defaultDog)
                .resizable()
        case .fish:
            Image(.defaultFish)
                .resizable()
        case .bird:
            Image(.defaultBird)
                .resizable()
        case .other:
            Image(.defaultOther)
                .resizable()
        }
    }
}
