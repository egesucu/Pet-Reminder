//
//  PetMigrationPlan.swift
//  Shared
//
//  Created by Ege Sucu on 26.06.2025.
//

import Foundation
import SwiftData

public enum PetMigrationPlan: SchemaMigrationPlan {
    public static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3, migrateV3toV4]
    }

    public static var schemas: [any VersionedSchema.Type] {
        [PetSchemaV1.self, PetSchemaV2.self, PetSchemaV3.self, PetSchemaV4.self]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: PetSchemaV1.self,
        toVersion: PetSchemaV2.self,
        willMigrate: { context in
            let pets = try context.fetch(FetchDescriptor<PetSchemaV1.Pet>())

            // Carry an existing selection through the legacy choice column.
            for pet in pets {
                switch pet.feedSelection {
                case .morning:
                    pet.choice = 0
                case .evening:
                    pet.choice = 1
                case .both:
                    pet.choice = 2
                case nil:
                    break
                }
            }

            try context.save()
        },
        didMigrate: { context in
            let pets = try context.fetch(FetchDescriptor<PetSchemaV2.Pet>())

            for pet in pets {
                pet.feedSelection = .fromLegacyChoice(pet.choice)
            }

            try context.save()
        }
    )

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: PetSchemaV2.self,
        toVersion: PetSchemaV3.self
    )

    static let migrateV3toV4 = MigrationStage.lightweight(
        fromVersion: PetSchemaV3.self,
        toVersion: PetSchemaV4.self
    )
}
