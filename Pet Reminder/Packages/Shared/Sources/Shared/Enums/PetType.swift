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
import OSLog

public enum PetType: String {
    case cat, dog, fish, bird, other
}

extension PetType: CaseIterable, Codable {}

extension PetType {
    public var localizedName: String {
        switch self {
        case .cat:
            let cat = String(localized: "Cat", bundle: .module)
            Logger.pets.info("Pet's localized type is: \(cat)")
            return cat
        case .dog:
            let dog = String(localized: "Dog", bundle: .module)
            Logger.pets.info("Pet's localized type is: \(dog)")
            return dog
        case .fish:
            let fish = String(localized: "Fish", bundle: .module)
            Logger.pets.info("Pet's localized type is: \(fish)")
            return fish
        case .bird:
            let bird = String(localized: "Bird", bundle: .module)
            Logger.pets.info("Pet's localized type is: \(bird)")
            return bird
        case .other:
            let other = String(localized: "Other", bundle: .module)
            Logger.pets.info("Pet's localized type is: \(other)")
            return other
        }
    }
    
    public var image: Image {
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
    
    public var uiImage: UIImage {
        return switch self {
        case .cat:
            UIImage(resource: .defaultCat)
        case .dog:
            UIImage(resource: .defaultDog)
        case .fish:
            UIImage(resource: .defaultFish)
        case .bird:
            UIImage(resource: .defaultBird)
        case .other:
            UIImage(resource: .defaultOther)
        }
    }
}
