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
    @State private var tappedTwice = false

    var body: some View {

        TabView(selection: $currentTab) {
            PetListView(reference: .petList)
                .tabItem {
                    Image(systemName: SFSymbols.pawPrint)
                }
                .onTapGesture(count: 2, perform: {
                    tappedTwice.toggle()
                })
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
    NavigationStack {
        HomeManagerView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
