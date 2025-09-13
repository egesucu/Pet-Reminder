//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
@preconcurrency import SwiftData

public typealias Pet = PetSchemaV2.Pet

public enum PetSchemaV2: @preconcurrency VersionedSchema {
    @MainActor public static let versionIdentifier = Schema.Version(2, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = ""
        public var birthday: Date = Date.now
        public var createdAt: Date?
        public var image: Data?
        // Store a stable, nonlocalized raw value to avoid actor isolation issues.
        private var feedSelectionRaw: String = "both"
        private var petTypeName: PetType.RawValue = PetType.other.rawValue

        @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?

        public init(
            birthday: Date = Date(),
            name: String = "",
            createdAt: Date? = nil,
            feedSelection: FeedSelection = .both,
            image: Data? = nil,
            feeds: [Feed]? = nil,
            vaccines: [Vaccine]? = nil,
            type: PetType = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.image = image
            self.feeds = feeds
            self.vaccines = vaccines
            self.type = type
            // Initialize raw storage from provided enum
            self.feedSelection = feedSelection
        }

        // Public enum-facing API for the rest of the app
        public var feedSelection: FeedSelection {
            get {
                Self.feedSelection(from: feedSelectionRaw)
            }
            set {
                feedSelectionRaw = Self.rawString(for: newValue)
            }
        }

        public var type: PetType {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }

        // MARK: - Mapping helpers (nonisolated, no UI dependencies)

        private static func rawString(for selection: FeedSelection) -> String {
            switch selection {
            case .morning: return "morning"
            case .evening: return "evening"
            case .both:    return "both"
            }
        }

        private static func feedSelection(from raw: String) -> FeedSelection {
            switch raw {
            case "morning": return .morning
            case "evening": return .evening
            default:        return .both
            }
        }
    }
}

public extension Pet {
    @MainActor static var preview: Pet {
        let firstPet = previews.first ?? .init(
            birthday: .now,
            name: "",
            createdAt: nil,
            feedSelection: .both,
            image: nil
        )
        return firstPet
    }

    @MainActor static var previews: [Pet] {
        var pets: [Pet] = []
        Strings.demoPets.forEach { petName in
            let randomType = PetType.allCases.randomElement() ?? .dog
            let pet = Pet(
                birthday: .randomDate(),
                name: petName,
                createdAt: .randomDate(),
                feedSelection: .both,
                image: randomType.uiImage.jpegData(compressionQuality: 0.8),
                type: randomType
            )
            pet.feeds = Feed.previews
            pet.vaccines = Vaccine.previews
            pets.append(pet)
        }
        return pets
    }
}
