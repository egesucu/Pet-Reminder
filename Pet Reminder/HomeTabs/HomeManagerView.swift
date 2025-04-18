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

struct HomeManagerView: View {
    @State private var currentTab: PetReminderTabs = .home

    let eventManager = EventViewModel()
    
    init() {}

    var body: some View {

        TabView(selection: $currentTab) {
            PetListView()
                .tabItem {
                    Image(systemSymbol: SFSymbol.pawprint)
                }
                .tag(PetReminderTabs.home)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            EventListView(eventVM: eventManager)
                .tabItem {
                    Image(systemSymbol: SFSymbol.listBullet)
                }
                .tag(PetReminderTabs.events)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            FindVetView()
                .tabItem {
                    Image(systemSymbol: SFSymbol.map)
                }
                .tag(PetReminderTabs.vet)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
            SettingsView()
                .tabItem {
                    Image(systemSymbol: SFSymbol.gearshape)
                }
                .tag(PetReminderTabs.settings)
                .toolbarBackground(Color(.systemBackground), for: .tabBar)
        }
        .tint(Color.label)
    }
}

#Preview {
    HomeManagerView()
}
