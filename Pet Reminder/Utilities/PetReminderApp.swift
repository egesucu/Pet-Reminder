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
    @State private var services: StoreServices?
    @Environment(\.scenePhase) private var scenePhase

    init() {
        _services = State(initialValue: Self.openStore())
    }

    private static func openStore() -> StoreServices? {
        do {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--store-screenshots") {
                return StoreServices(container: DataController.screenshotContainer())
            }
            #endif
            return StoreServices(container: try DataController.productionContainer())
        } catch {
            let failure = error as NSError
            Logger.pets.error(
                "Could not open the pet store (\(failure.domain, privacy: .public) \(failure.code)): \(String(reflecting: error), privacy: .private)"
            )
            return nil
        }
    }

    var body: some Scene {
        WindowGroup("Pet Reminder", id: "main", for: PetWindowState.self) { $windowState in
            if let services {
                petWindow($windowState, services: services)
            } else {
                ContentUnavailableView {
                    Label(SharedStrings.resource("Could not open pet data"), systemImage: "exclamationmark.triangle")
                } actions: {
                    Button(SharedStrings.retry) {
                        services = Self.openStore()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .commands { PetWindowCommands() }
    }

    private func petWindow(_ windowState: Binding<PetWindowState?>, services: StoreServices) -> some View {
        PetReminderWindow(petID: Binding(
            get: { windowState.wrappedValue?.petID },
            set: { id in
                if windowState.wrappedValue == nil { windowState.wrappedValue = PetWindowState(petID: id) }
                else { windowState.wrappedValue?.petID = id }
            }
        ), intentInbox: services.navigation,
                          isCapturingScreenshots: isCapturingScreenshots)
        .task {
            if !isCapturingScreenshots {
                services.refreshIntegrations(reloadWidgetTimelines: true)
                await refreshNotificationLocalizations(in: services.container)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active && !isCapturingScreenshots {
                services.refreshIntegrations(reloadWidgetTimelines: true)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave).receive(on: RunLoop.main)) { _ in
            // The saving context may outlive its container by the time this event is delivered.
            // Reconcile our own container without dereferencing the notification object.
            if !isCapturingScreenshots { services.refreshIntegrations() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange).receive(on: RunLoop.main)) { _ in
            if !isCapturingScreenshots { services.refreshIntegrations() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification).receive(on: RunLoop.main)) { notification in
            guard !isCapturingScreenshots,
                  let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event,
                  event.type == .import, event.endDate != nil, event.succeeded else { return }
            services.refreshIntegrations()
        }
        .notification(notificationManager)
        .environment(services.care)
        .modelContainer(services.container)
    }

    private var isCapturingScreenshots: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("--store-screenshots")
        #else
        false
        #endif
    }

    @MainActor
    private func refreshNotificationLocalizations(in container: ModelContainer) async {
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

@MainActor
private struct StoreServices {
    let container: ModelContainer
    let navigation: AppNavigationCoordinator
    let care: PetCareService
    private let spotlight: PetSpotlightIndexer
    private let widgets: PetWidgetPublisher

    init(container: ModelContainer) {
        self.container = container
        let navigation = AppNavigationCoordinator()
        self.navigation = navigation
        let care = PetCareService(container: container)
        self.care = care
        let spotlight = PetSpotlightIndexer(service: care)
        self.spotlight = spotlight
        let widgets = PetWidgetPublisher(container: container, service: care)
        self.widgets = widgets
        let widgetFeeding = widgets.feedingAction()
        unsafe AppDependencyManager.shared.add(dependency: care)
        unsafe AppDependencyManager.shared.add(dependency: navigation)
        unsafe AppDependencyManager.shared.add(dependency: spotlight)
        unsafe AppDependencyManager.shared.add(dependency: widgetFeeding)
    }

    func refreshIntegrations(reloadWidgetTimelines: Bool = false) {
        spotlight.scheduleRefresh()
        widgets.scheduleRefresh(reloadTimelines: reloadWidgetTimelines)
    }
}
