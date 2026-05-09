//
//  PetSchemaV1.swift
//  Shared
//
//  Created by Ege Sucu on 26.06.2025.
//

import Foundation
import SwiftData

public enum PetSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = String.empty
        public var birthday: Date = Date.now
        public var choice: Int = 0
        public var createdAt: Date?
        public var image: Data?
        public var feedSelection: FeedSelection?
        private var petTypeName: Kind.RawValue = Kind.other.rawValue

        @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?

        public init(
            birthday: Date = Date(),
            name: String = .empty,
            createdAt: Date? = nil,
            feedSelection: FeedSelection? = nil,
            image: Data? = nil,
            feeds: [Feed]? = nil,
            vaccines: [Vaccine]? = nil,
            kind: Kind = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.image = image
            self.feedSelection = feedSelection
            self.feeds = feeds
            self.vaccines = vaccines
            self.kind = kind
        }

        var kind: Kind {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }
    }
}
