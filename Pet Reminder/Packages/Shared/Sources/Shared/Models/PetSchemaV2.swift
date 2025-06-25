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
        public var feedSelection: FeedSelection = FeedSelection.both
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
            self.feedSelection = feedSelection
            self.feeds = feeds
            self.vaccines = vaccines
            self.type = type
        }
        
        public var type: PetType {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }
    }
}
