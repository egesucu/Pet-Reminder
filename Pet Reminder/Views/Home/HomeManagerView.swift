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
            EventListView()
                .tabItem {
                    Image(systemName: SFSymbols.list)
                }
                .tag(PetReminderTabs.events)
            FindVetView()
                .tabItem {
                    Image(systemName: SFSymbols.map)
                }
                .tag(PetReminderTabs.vet)
            SettingsView()
                .tabItem {
                    Image(systemName: SFSymbols.settings)
                }
                .tag(PetReminderTabs.settings)
        }
        .tint(.dynamicBlack)

    }
}

#Preview {
    HomeManagerView()
}
