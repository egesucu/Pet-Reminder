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
import OSLog
import Shared

@main
struct PetReminderApp: App {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @State private var notificationManager = NotificationManager.shared
    @State private var eventManager = EventManager.shared

    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Pet.self,
                migrationPlan: PetMigrationPlan.self
            )
        } catch {
            fatalError("Failed to initialize model container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            if helloSeen {
                HomeManagerView()
            } else {
                HelloView()
            }
        }
        .environment(notificationManager)
        .environment(eventManager)
        .modelContainer(container)
    }
}
