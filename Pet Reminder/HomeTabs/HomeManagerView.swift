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

    init() {}

    var body: some View {

        TabView(selection: $currentTab) {
            Tab(value: PetReminderTabs.home) {
                PetListView()
                    .environment(notificationManager)
            } label: {
                Image(systemSymbol: SFSymbol.pawprint)
            }
            Tab(value: PetReminderTabs.events) {
                EventListView()
                    .environment(eventManager)
            } label: {
                Image(systemSymbol: SFSymbol.listBullet)
            }
            Tab(value: PetReminderTabs.settings) {
                SettingsView()
                    .environment(notificationManager)
            } label: {
                Image(systemSymbol: SFSymbol.gearshape)
            }
            Tab(value: PetReminderTabs.vet, role: .search) {
                FindVetView()
            } label: {
                Image(systemSymbol: SFSymbol.magnifyingglass)
            }
        }
        .tint(.accent)
    }
}

#Preview {
    HomeManagerView()
        .environment(NotificationManager.shared)
        .environment(EventManager.demo)
        .modelContainer(DataController.previewContainer)
}
