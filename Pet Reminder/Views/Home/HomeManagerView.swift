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
                    Image(systemName: currentTab != .home ? SFSymbols.person : SFSymbols.personSelected)
                }
                .tag(PetReminderTabs.home)
            EventListView()
                .tabItem {
                    Image(systemName: currentTab != .events ? SFSymbols.list : SFSymbols.listSelected)
                }
                .tag(PetReminderTabs.events)
            FindVetView()
                .tabItem {
                    Image(systemName: currentTab != .vet ? SFSymbols.map : SFSymbols.mapSelected)
                }
                .tag(PetReminderTabs.vet)
            SettingsView()
                .tabItem {
                    Image(systemName: currentTab != .settings ? SFSymbols.settings : SFSymbols.settingsSelected)
                }
                .tag(PetReminderTabs.settings)
        }
        .tint(.dynamicBlack)

    }
}

#Preview {
    HomeManagerView()
}
