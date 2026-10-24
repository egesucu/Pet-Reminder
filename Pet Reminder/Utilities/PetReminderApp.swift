//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Intro
import VetFinder
import Events
import Reminders
import SwiftUI
import CloudKit
import SwiftData
import OSLog
import Shared
import SharedUI
import PetCare
import AppIntents
import Combine
import CoreData

@main
struct PetReminderApp: App {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @State private var notificationManager = NotificationManager()
    @State private var eventManager = EventManager()
    @State private var vetService = VetServiceImplementation()
    @State private var navigation: AppNavigationCoordinator
    @State private var careService: PetCareService
    @Environment(\.scenePhase) private var scenePhase
    private let spotlight: PetSpotlightIndexer

    let container: ModelContainer

    init() {
        let navigation = AppNavigationCoordinator()
        _navigation = State(initialValue: navigation)
        container = Self.makeContainer()
        let service = PetCareService(container: container)
        _careService = State(initialValue: service)
        let spotlight = PetSpotlightIndexer(service: service)
        self.spotlight = spotlight
        unsafe AppDependencyManager.shared.add(dependency: service)
        unsafe AppDependencyManager.shared.add(dependency: navigation)
        unsafe AppDependencyManager.shared.add(dependency: spotlight)
    }

    private static func makeContainer() -> ModelContainer {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--store-screenshots") {
            return DataController.screenshotContainer()
        }
        #endif
        do {
            return try DataController.productionContainer()
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
                    IntroView { helloSeen = true }
                }
            }
            .onOpenURL { navigation.handle($0) }
            .task {
                if !isCapturingScreenshots {
                    spotlight.scheduleRefresh()
                    await refreshNotificationLocalizations()
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active && !isCapturingScreenshots { spotlight.scheduleRefresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave).receive(on: RunLoop.main)) { _ in
                // The saving context may outlive its container by the time this event is delivered.
                // Reconcile our own container without dereferencing the notification object.
                if !isCapturingScreenshots { spotlight.scheduleRefresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange).receive(on: RunLoop.main)) { _ in
                if !isCapturingScreenshots { spotlight.scheduleRefresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification).receive(on: RunLoop.main)) { notification in
                guard !isCapturingScreenshots,
                      let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                        as? NSPersistentCloudKitContainer.Event,
                      event.type == .import, event.endDate != nil, event.succeeded else { return }
                spotlight.scheduleRefresh()
            }
        }
        .notification(notificationManager)
        .environment(eventManager)
        .environment(vetService)
        .environment(navigation)
        .environment(careService)
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
