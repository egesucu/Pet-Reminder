//
//  HomeManagerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HomeManagerView: View {
    @State private var currentTab: PetReminderTabs = .home
    var storeManager: StoreManager

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
            SettingsView(storeManager: storeManager)
                .tabItem {
                    Image(systemName: currentTab != .settings ? SFSymbols.settings : SFSymbols.settingsSelected)
                }
                .tag(PetReminderTabs.settings)
        }
        .accentColor(.dynamicBlack)

    }
}

struct HomeManager_Previews: PreviewProvider {
    static var previews: some View {
        HomeManagerView(storeManager: StoreManager())
    }
}
