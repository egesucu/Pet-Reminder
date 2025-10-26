//
//  HomeManagerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SFSafeSymbols
import SwiftData

struct HomeManagerView: View {
    @State private var currentTab: PetReminderTabs = .home
    @Environment(EventManager.self) private var eventManager
    @Environment(NotificationManager.self) private var notificationManager

    // One navigation path per tab to preserve stack state
    @State private var homePath = NavigationPath()
    @State private var eventsPath = NavigationPath()
    @State private var settingsPath = NavigationPath()
    @State private var vetPath = NavigationPath()

    // Optional: carry a pet name from deep link; your PetListView can observe this via NotificationCenter
    @State private var pendingPetNameFromDeepLink: String?

    init() {}

    var body: some View {
        TabView(selection: $currentTab) {
            // HOME TAB
            Tab(value: PetReminderTabs.home) {
                NavigationStack(path: $homePath) {
                    PetListView()
                        .environment(notificationManager)
                        .navigationTitle("pet_name_title")
                        .onChange(of: pendingPetNameFromDeepLink) { _, newValue in
                            /// Forward deep link pet name to the list via NotificationCenter
                            /// so you don't need to change PetListView's API
                            if let name = newValue {
                                NotificationCenter.default.post(name: .openPetByName, object: name)
                                pendingPetNameFromDeepLink = nil
                            }
                        }
                }
            } label: {
                Label("home_tab_title", systemSymbol: .pawprint)
            }

            // EVENTS TAB
            Tab(value: PetReminderTabs.events) {
                NavigationStack(path: $eventsPath) {
                    EventListView()
                        .environment(eventManager)
                        .navigationTitle("events_tab_title")
                }
            } label: {
                Label("events_tab_title", systemSymbol: .listBullet)
            }

            // SETTINGS TAB
            Tab(value: PetReminderTabs.settings) {
                NavigationStack(path: $settingsPath) {
                    SettingsView()
                        .environment(notificationManager)
                        .navigationTitle("settings_tab_title")
                }
            } label: {
                Label("settings_tab_title", systemSymbol: .gearshape)
            }

            // FIND VET TAB
            Tab(value: PetReminderTabs.vet, role: .search) {
                NavigationStack(path: $vetPath) {
                    FindVetView()
                }
            } label: {
                Label("find_vet_title", systemSymbol: .magnifyingglass)
            }
        }
        .tint(.accent)
        .onOpenURL { url in
            handle(url)
        }
    }
}

// MARK: - Deep Link Handling
private extension HomeManagerView {
    func handle(_ url: URL) {
        guard url.scheme?.lowercased() == "petreminder" else { return }

        // Expected forms:
        // petreminder://home
        // petreminder://home/<pet-name>
        // petreminder://events
        // petreminder://findVet
        // petreminder://settings
        guard let host = url.host?.lowercased() else { return }

        switch host {
        case "home":
            currentTab = .home
            // if there is a trailing component, treat it as a pet name slug
            let comps = url.pathComponents.filter { $0 != "/" }
            if let petName = comps.first, !petName.isEmpty {
                // save to state; forwarded to PetListView via NotificationCenter
                pendingPetNameFromDeepLink = petName
            }
        case "events":
            currentTab = .events
        case "findvet":
            currentTab = .vet
        case "settings":
            currentTab = .settings
        case "add":
            currentTab = .home
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .openAddPet, object: nil)
            }
        default:
            break
        }
    }
}

// Notification your PetListView can observe to open a pet by name
extension Notification.Name {
    static let openPetByName = Notification.Name("OpenPetByNameNotification")
    static let openAddPet = Notification.Name("OpenAddPetSheetNotification")
}

#if DEBUG
#Preview {
    HomeManagerView()
        .environment(NotificationManager.shared)
        .environment(EventManager.demo)
        .modelContainer(DataController.previewContainer)
}
#endif
