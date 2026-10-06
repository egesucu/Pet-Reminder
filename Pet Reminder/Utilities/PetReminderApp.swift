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
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--store-screenshots") {
            container = DataController.screenshotContainer()
            return
        }
        #endif
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
            Group {
                if helloSeen || isCapturingScreenshots {
                    HomeManager()
                } else {
                    Hello()
                }
            }
            .task {
                if !isCapturingScreenshots {
                    await refreshNotificationLocalizations()
                }
            }
        }
        .notification(notificationManager)
        .environment(eventManager)
        .modelContainer(container)
    }

    private var isCapturingScreenshots: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("--store-screenshots")
        #else
        false
        #endif
    }

    @MainActor
    private func refreshNotificationLocalizations() async {
        do {
            let modelContext = ModelContext(container)
            let pets = try modelContext.fetch(FetchDescriptor<Pet>())
            try await notificationManager.refreshNotificationLocalizations(for: pets)
        } catch {
            Logger.notifications.error(
                "Failed to refresh notification localizations: \(error.localizedDescription)"
            )
        }
    }
}
