//
//  PetSchemaV3.swift
//  Shared
//
//  Created by Ege Sucu on 23.04.2026.
//

import Foundation
import SwiftData

public typealias Pet = PetSchemaV3.Pet

public enum PetSchemaV3: VersionedSchema {
    public static let versionIdentifier = Schema.Version(3, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = String.empty
        public var birthday: Date = Date.now
        public var createdAt: Date?
        public var image: Data?
        // Store a stable, nonlocalized raw value to avoid actor isolation issues.
        private var feedSelectionRaw: String = "both"
        @Attribute(originalName: "petTypeName")
        private var kindName: Kind.RawValue = Kind.other.rawValue

        @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?

        public init(
            birthday: Date = Date(),
            name: String = .empty,
            createdAt: Date? = nil,
            feedSelection: FeedSelection = .both,
            image: Data? = nil,
            feeds: [Feed]? = nil,
            vaccines: [Vaccine]? = nil,
            kind: Kind = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.image = image
            self.feeds = feeds
            self.vaccines = vaccines
            self.kind = kind
            self.feedSelection = feedSelection
        }

        public var feedSelection: FeedSelection {
            get {
                Self.feedSelection(from: feedSelectionRaw)
            }
            set {
                feedSelectionRaw = Self.rawString(for: newValue)
            }
        }

        public var kind: Kind {
            get { .init(rawValue: kindName) ?? .other }
            set { kindName = newValue.rawValue }
        }

        private static func rawString(for selection: FeedSelection) -> String {
            switch selection {
            case .morning: 
                return "morning"
            case .evening: 
                return "evening"
            case .both:    
                return "both"
            }
        }

        private static func feedSelection(from raw: String) -> FeedSelection {
            switch raw {
            case "morning":
                return .morning
            case "evening":
                return .evening
            default:
                return .both
            }
        }
    }
}

public extension Pet {
    @MainActor static var preview: Pet {
        let firstPet = previews.first ?? .init(
            birthday: .now,
            name: .empty,
            createdAt: nil,
            feedSelection: .both,
            image: nil
        )
        return firstPet
    }

    @MainActor static var previews: [Pet] {
        var pets: [Pet] = []
        Strings.demoPets.forEach { petName in
            let randomKind = Kind.allCases.randomElement() ?? .dog
            let pet = Pet(
                birthday: .randomDate(),
                name: petName,
                createdAt: .randomDate(),
                feedSelection: .both,
                image: randomKind.uiImage.jpegData(compressionQuality: 0.8),
                kind: randomKind
            )
            pet.feeds = Feed.previews
            pet.vaccines = Vaccine.previews
            pets.append(pet)
        }
        return pets
    }
}
