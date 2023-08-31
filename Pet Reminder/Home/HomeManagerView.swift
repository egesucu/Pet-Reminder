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
    @State private var tappedTwice = false

    var handler: Binding<PetReminderTabs> { Binding(
            get: { self.currentTab },
            set: {
                if $0 == self.currentTab {
                    tappedTwice.toggle()
                }
                self.currentTab = $0
            }
        )}

    var body: some View {

        TabView(selection: handler) {
            PetListView(reference: .petList)
                .tabItem {
                    Image(systemName: SFSymbols.pawPrint)
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}