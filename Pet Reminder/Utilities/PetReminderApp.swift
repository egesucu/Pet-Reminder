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
    @State private var notificationManager = NotificationManager()
    @State private var navigation: AppNavigationCoordinator
    @State private var careService: PetCareService
    @Environment(\.scenePhase) private var scenePhase
    private let spotlight: PetSpotlightIndexer
    private let widgets: PetWidgetPublisher

    let container: ModelContainer

    init() {
        let navigation = AppNavigationCoordinator()
        _navigation = State(initialValue: navigation)
        container = Self.makeContainer()
        let service = PetCareService(container: container)
        _careService = State(initialValue: service)
        let spotlight = PetSpotlightIndexer(service: service)
        self.spotlight = spotlight
        let widgets = PetWidgetPublisher(container: container, service: service)
        self.widgets = widgets
        let widgetFeeding = widgets.feedingAction()
        unsafe AppDependencyManager.shared.add(dependency: service)
        unsafe AppDependencyManager.shared.add(dependency: navigation)
        unsafe AppDependencyManager.shared.add(dependency: spotlight)
        unsafe AppDependencyManager.shared.add(dependency: widgetFeeding)
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
        WindowGroup("Pet Reminder", id: "main", for: PetWindowState.self) { $windowState in
            PetReminderWindow(petID: Binding(
                get: { windowState?.petID },
                set: { id in
                    if windowState == nil { windowState = PetWindowState(petID: id) }
                    else { windowState?.petID = id }
                }
            ), intentInbox: navigation,
                              isCapturingScreenshots: isCapturingScreenshots)
            .task {
                if !isCapturingScreenshots {
                    refreshIntegrations(reloadWidgetTimelines: true)
                    await refreshNotificationLocalizations()
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active && !isCapturingScreenshots {
                    refreshIntegrations(reloadWidgetTimelines: true)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave).receive(on: RunLoop.main)) { _ in
                // The saving context may outlive its container by the time this event is delivered.
                // Reconcile our own container without dereferencing the notification object.
                if !isCapturingScreenshots { refreshIntegrations() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange).receive(on: RunLoop.main)) { _ in
                if !isCapturingScreenshots { refreshIntegrations() }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification).receive(on: RunLoop.main)) { notification in
                guard !isCapturingScreenshots,
                      let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                        as? NSPersistentCloudKitContainer.Event,
                      event.type == .import, event.endDate != nil, event.succeeded else { return }
                refreshIntegrations()
            }
        }
        .notification(notificationManager)
        .environment(careService)
        .modelContainer(container)
        .commands { PetWindowCommands() }
    }

    private var isCapturingScreenshots: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("--store-screenshots")
        #else
        false
        #endif
    }

    private func refreshIntegrations(reloadWidgetTimelines: Bool = false) {
        spotlight.scheduleRefresh()
        widgets.scheduleRefresh(reloadTimelines: reloadWidgetTimelines)
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
