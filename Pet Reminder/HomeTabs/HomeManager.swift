//
//  HomeManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import AppIntents
import VetFinder
import Events
import Reminders
import Pets
import Settings
import SwiftUI
import Shared
import SharedUI
import PetCare
import SwiftData
#if DEBUG
import PreviewSupport
#endif

struct HomeManager: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @Environment(VetServiceImplementation.self) private var vetService
    @Environment(EventManager.self) private var eventManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(AppNavigationCoordinator.self) private var navigation

    init() {}

    var body: some View {
        @Bindable var navigation = navigation
        TabView(selection: $navigation.selectedTab) {
            // HOME TAB
            Tab(value: PetReminderTabs.home) {
                PetList(request: navigation.pendingRequest, onRequestHandled: navigation.consume)
            } label: {
                Label(SharedStrings.homeTabTitle, systemImage: "pawprint")
            }

            // EVENTS TAB
            Tab(value: PetReminderTabs.events) {
                EventList()
                    .environment(eventManager)
            } label: {
                Label(SharedStrings.eventTabTitle, systemImage: "list.bullet")
            }

            // SETTINGS TAB
            Tab(value: PetReminderTabs.settings) {
                Settings(managePets: { AnyView(PetChangeList()) })
                    .environment(notificationManager)
            } label: {
                Label(SharedStrings.settingsTabTitle, systemImage: "gearshape")
            }

            // FIND VET TAB
            Tab(value: PetReminderTabs.vet, role: .prominent) {
                FindVet(service: vetService)
            } label: {
                Label(SharedStrings.findVetTitle, systemImage: "magnifyingglass")
            }
        }
        .defaultTabBarPlacement(.tabBar)
        .tint(.accent)
        .onChange(of: pets.map { "\($0.intentID?.uuidString ?? ""):\($0.name)" }, initial: true) { _, _ in
            PetAppShortcuts.updateAppShortcutParameters()
        }

    }
}

#if DEBUG
#Preview {
    HomeManager()
        .notification(NotificationManager())
        .environment(EventManager(isDemo: true))
        .environment(VetServiceImplementation())
        .environment(AppNavigationCoordinator())
        .environment(PetCareService(container: PreviewData.previewContainer))
        .modelContainer(PreviewData.previewContainer)
}
#endif
