//
//  PetSchemaV1AndMigration.swift
//  Pet Reminder
//
//  Created by Migration on 2025-09-13.
//

import Foundation
@preconcurrency import SwiftData
import Shared

// MARK: - Legacy v1 schema (minimal needed for migration, aligned with tests)

enum PetSchemaV1: @preconcurrency VersionedSchema {
    @MainActor static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    final class Pet {
        var name: String = ""
        var birthday: Date = Date.now
        var choice: Int = 0
        var createdAt: Date?
        var image: Data?
        // Optional in v1 (tests pass nil and .morning)
        var feedSelection: FeedSelection?
        // Store pet type name as raw string for forward compatibility
        private var petTypeName: PetType.RawValue = PetType.other.rawValue

        // Relationships intentionally omitted to avoid cross-version inverse key-path issues.

        // Keep initializer signature compatible with tests; ignore feeds/vaccines parameters.
        init(
            birthday: Date = Date(),
            name: String = "",
            createdAt: Date? = nil,
            feedSelection: FeedSelection? = nil,
            image: Data? = nil,
            feeds: [Any]? = nil,      // placeholders to satisfy call sites; not stored
            vaccines: [Any]? = nil,   // placeholders to satisfy call sites; not stored
            type: PetType = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.image = image
            self.feedSelection = feedSelection
            self.type = type
        }

        var type: PetType {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }
    }
}
