//
//  HomeManagerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HomeManagerView: View {
    @State private var currentTab: PetReminderTabs = .home

    var body: some View {

        TabView(selection: $currentTab) {
            HomeView()
                .tabItem {
                    Image(systemName: SFSymbols.person)
                }
                .tag(PetReminderTabs.home)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            EventListView()
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
        .tint(.dynamicBlack)

    }
}

#Preview {
    HomeManagerView()
}
