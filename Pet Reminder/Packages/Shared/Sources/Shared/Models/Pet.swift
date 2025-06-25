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
import UIKit.UIImage

public typealias Pet = PetSchemaV2.Pet

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

public extension Pet {
    static var preview: Pet {
        let firstPet = previews.first ?? .init(
            birthday: .now,
            name: "",
            createdAt: nil,
            feedSelection: .both,
            image: nil
        )
        return firstPet
    }

    static var previews: [Pet] {
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

public enum PetMigrationPlan: SchemaMigrationPlan {
    public static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    public static var schemas: [any VersionedSchema.Type] {
        [PetSchemaV1.self, PetSchemaV2.self]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: PetSchemaV1.self,
        toVersion: PetSchemaV2.self,
        willMigrate: { context in
            let users = try context.fetch(FetchDescriptor<PetSchemaV1.Pet>())
            
            for user in users {
                
                if user.feedSelection == nil {
                    user.feedSelection = .both
                }
                
                let choice = user.choice
                switch choice {
                case 0: // morning
                    user.feedSelection = .morning
                case 1:
                    user.feedSelection = .evening
                default:
                    user.feedSelection = .both
                }
                
            }

            try context.save()
        }, didMigrate: nil
    )
}
