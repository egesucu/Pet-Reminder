//
//  RollbackMigrationPlan.swift
//  Shared
//
//  Created by Ege Sucu on 26.06.2025.
//

import Foundation
@preconcurrency import SwiftData

public enum RollbackMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [PetSchemaV2.self, PetSchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        [migrateV2toV1]
    }

    // MARK: Migration Stages

    static let migrateV2toV1 = MigrationStage.custom(
        fromVersion: PetSchemaV2.self,
        toVersion: PetSchemaV1.self,
        willMigrate: nil,
        didMigrate: nil
    )
}
