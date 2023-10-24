//
//  HomeManagerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog

struct HomeManagerView: View {
    @State private var currentTab: PetReminderTabs = .home
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {

        TabView(selection: $currentTab) {
            PetListView()
                .tabItem {
                    Image(systemName: SFSymbols.pawPrint)
                }
                .tag(PetReminderTabs.home)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            EventListView(eventVM: EventManager())
                .tabItem {
                    Image(systemName: SFSymbols.list)
                }
                .tag(PetReminderTabs.events)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            FindVetView()
                .tabItem {
                    Image(systemName: SFSymbols.map)
                }
                .tag(PetReminderTabs.vet)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            SettingsView()
                .tabItem {
                    Image(systemName: SFSymbols.settings)
                }
                .tag(PetReminderTabs.settings)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
        }
        .tint(Color.label)

    }
}

#Preview {
    HomeManagerView()
        .environment(NotificationManager())
}
