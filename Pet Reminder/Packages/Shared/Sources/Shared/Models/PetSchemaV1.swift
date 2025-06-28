//
//  PetSchemaV1.swift
//  Shared
//
//  Created by Ege Sucu on 26.06.2025.
//

import Foundation
@preconcurrency import SwiftData

public enum PetSchemaV1: @preconcurrency VersionedSchema {
    @MainActor public static var versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = ""
        public var birthday: Date = Date.now
        public var choice: Int = 0
        public var createdAt: Date?
        public var image: Data?
        public var feedSelection: FeedSelection?
        private var petTypeName: PetType.RawValue = PetType.other.rawValue
        
        @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?
        
        public init(
            birthday: Date = Date(),
            name: String = "",
            createdAt: Date? = nil,
            feedSelection: FeedSelection? = nil,
            image: Data? = nil,
            feeds: [Feed]? = nil,
            vaccines: [Vaccine]? = nil,
            type: PetType = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.image = image
            self.feedSelection = feedSelection
            self.feeds = feeds
            self.vaccines = vaccines
            self.type = type
        }
        
        var type: PetType {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }
    }
}
