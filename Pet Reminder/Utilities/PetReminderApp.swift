//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CloudKit
import SwiftData
import CoreData
import OSLog
import Shared

@main
struct PetReminderApp: App {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @Environment(\.undoManager) var undoManager
    @State private var notificationManager = NotificationManager()
    
    var container: ModelContainer
    
    init() {
        do {
            self.container = try setupModelContainer()
        } catch {
            fatalError("Failed to initialize model container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            if helloSeen {
                HomeManagerView()
                    .environment(notificationManager)
            } else {
                HelloView()
                    .environment(notificationManager)
            }
        }
        .modelContainer(container)
    }
    
}

private let logger = Logger(subsystem: "com.egesucu.Pet-Reminder", category: "Model")

@discardableResult
func setupModelContainer(
    for versionedSchema: any VersionedSchema.Type = PetSchemaV2.self,
    url: URL? = nil,
    useCloudKit: Bool = true,
    rollback: Bool = false
) throws -> ModelContainer {
    
#if DEBUG
    // disable CloudKit when running tests
    var useCloudKit = useCloudKit
    let runningTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil // !TODO: is this safe?
    if (runningTest) {
        logger.info("setup - disabling CloudKit on testing run.")
        useCloudKit = false
    }
#endif
    
    do {
        logger.info("setup - versionedSchema: \(String(describing: versionedSchema)), url: \(String(describing: url)), useCloudKit: \(useCloudKit), rollback: \(rollback)")
        
        let schema = Schema(versionedSchema: versionedSchema)
        logger.info("setup - schema: \(String(describing: schema))")
        
        var config: ModelConfiguration
        if let url = url {
            config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: useCloudKit ? .automatic : .none)
        } else {
            config = ModelConfiguration(schema: schema, cloudKitDatabase: useCloudKit ? .automatic : .none)
        }
        logger.info("setup - config: \(String(describing: config))")
        
#if DEBUG
        if useCloudKit {
            // TODO: does this run on an iOS device w/o iCloud account?
            try initCloudKitDevelopmentSchema(config: config)
        }
#endif
        
        let container = try ModelContainer(
            for: schema,
            migrationPlan: rollback ? RollbackMigrationPlan.self : PetMigrationPlan.self,
            configurations: [config]
        )
        logger.info("setup -> \(String(describing: container))")
        
        return container
    } catch {
        logger.error("setup - \(error)")
        throw ModelError.setup(error: error)
    }
}

/// Initialize the CloudKit development schema: https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices#Initialize-the-CloudKit-development-schema
func initCloudKitDevelopmentSchema(config: ModelConfiguration) throws {
    logger.info("initCloudKitDevelopmentSchema()")
    
    // Use an autorelease pool to make sure Swift deallocates the persistent
    // container before setting up the SwiftData stack.
    try autoreleasepool {
        let desc = NSPersistentStoreDescription(url: config.url)
        let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.apple-samplecode.SwiftDataAnimalsEW3E677XMJ")
        desc.cloudKitContainerOptions = opts
        // Load the store synchronously so it completes before initializing the
        // CloudKit schema.
        desc.shouldAddStoreAsynchronously = false
        if let mom = NSManagedObjectModel.makeManagedObjectModel(for: PetSchemaV2.models) {
            let container = NSPersistentCloudKitContainer(name: config.name, managedObjectModel: mom)
            container.persistentStoreDescriptions = [desc]
            container.loadPersistentStores {_, err in
                if let err {
                    fatalError(err.localizedDescription)
                }
            }
            // Initialize the CloudKit schema after the store finishes loading.
            try container.initializeCloudKitSchema()
            // Remove and unload the store from the persistent container.
            if let store = container.persistentStoreCoordinator.persistentStores.first {
                try container.persistentStoreCoordinator.remove(store)
            }
        }
    }
}

enum ModelError: LocalizedError {
    case setup(error: any Error)
}
