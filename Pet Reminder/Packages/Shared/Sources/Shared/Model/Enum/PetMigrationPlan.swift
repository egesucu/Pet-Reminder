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
        [migrateV2toV3, migrateV3toV4]
    }

    public static var schemas: [any VersionedSchema.Type] {
        [PetSchemaV1.self, PetSchemaV2.self, PetSchemaV3.self, PetSchemaV4.self]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: PetSchemaV1.self,
        toVersion: PetSchemaV2.self,
        willMigrate: { context in
            let users = try context.fetch(FetchDescriptor<PetSchemaV1.Pet>())
            /*
             We want to remove choice & make sure a feed selection is present.
             This removes nil option from old db & set a selection if previously
             given by choice value.
             */
            for user in users where user.feedSelection == nil {
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

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: PetSchemaV2.self,
        toVersion: PetSchemaV3.self
    )
    
    static let migrateV3toV4 = MigrationStage.lightweight(
        fromVersion: PetSchemaV3.self,
        toVersion: PetSchemaV4.self
    )
}
