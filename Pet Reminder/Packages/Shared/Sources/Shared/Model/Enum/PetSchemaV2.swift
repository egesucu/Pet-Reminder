//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import SwiftData

public enum PetSchemaV2: VersionedSchema {
    public static let versionIdentifier = Schema.Version(2, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = String.empty
        public var birthday: Date = Date.now
        var choice: Int = 0
        public var createdAt: Date?
        public var image: Data?
        // Store a stable, nonlocalized raw value to avoid actor isolation issues.
        private var feedSelectionRaw: String = "both"
        private var petTypeName: Kind.RawValue = Kind.other.rawValue

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

        public var kind: Kind {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }

        // MARK: - Mapping helpers (nonisolated, no UI dependencies)

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
