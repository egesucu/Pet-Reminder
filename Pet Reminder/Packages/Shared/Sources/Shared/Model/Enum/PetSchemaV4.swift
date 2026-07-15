//
//  PetSchemaV4.swift
//  Shared
//
//  Created by Sucu, Ege on 08.06.26.
//

import Foundation
import SwiftData

public typealias Pet = PetSchemaV4.Pet

public enum PetSchemaV4: VersionedSchema {
    public static let versionIdentifier = Schema.Version(4, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = String.empty
        public var birthday: Date = Date.now
        public var createdAt: Date?
        public var image: Data?
        public var breed: String?
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
            breed: String? = nil,
            feeds: [Feed]? = nil,
            vaccines: [Vaccine]? = nil,
            kind: Kind = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.breed = breed
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
    static func cleanedName(for name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedName(for name: String) -> String {
        cleanedName(for: name)
            .folding(options: [.diacriticInsensitive, .widthInsensitive], locale: .current)
            .lowercased()
    }

    static func exactNameFetchDescriptor(for name: String) -> FetchDescriptor<Pet> {
        let cleanedName = cleanedName(for: name)
        var descriptor = FetchDescriptor<Pet>(
            predicate: #Predicate<Pet> { pet in
                pet.name == cleanedName
            }
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    func hasNameMatching(_ name: String) -> Bool {
        Self.normalizedName(for: self.name) == Self.normalizedName(for: name)
    }

    @MainActor static var preview: Pet {
        let firstPet = previews.first ?? .init(
            birthday: .now,
            name: .empty,
            createdAt: nil,
            feedSelection: .both,
            image: nil,
            breed: "Husky",
            kind: .dog
        )
        return firstPet
    }

    @MainActor static var previews: [Pet] {
        var pets: [Pet] = []
        Strings.demoPets.forEach { petName in
            let randomKind = Kind.allCases.randomElement() ?? .dog
            
            let randomBreed: String? = switch randomKind {
            case .cat:
                "Aegean"
            case .dog:
                "Beagle"
            case .fish:
                "Queen Angelfish"
            case .bird:
                "Australian King Parrot"
            case .other:
                nil
            }
            
            let pet = Pet(
                birthday: .randomDate(),
                name: petName,
                createdAt: .randomDate(),
                feedSelection: .both,
                image: randomKind.uiImage.jpegData(compressionQuality: 0.8),
                breed: randomBreed,
                kind: randomKind
            )
            pet.feeds = Feed.previews
            pet.vaccines = Vaccine.previews
            pets.append(pet)
        }
        return pets
    }
}
