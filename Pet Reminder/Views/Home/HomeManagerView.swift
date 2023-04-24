//
//  HomeManagerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct HomeManagerView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    @State private var currentTab : PetReminderTabs = .home
    @StateObject var storeManager : StoreManager
    
    var body: some View {
        
        TabView(selection: $currentTab) {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: currentTab != .home ? "person.crop.circle" : "person.crop.circle.fill")
                }
                .tag(PetReminderTabs.home)
            EventListView()
                .tabItem {
                    Image(systemName: currentTab != .events ? "list.bullet" : "list.bullet.indent")
                }
                .tag(PetReminderTabs.events)
            FindVetView()
                .tabItem {
                    Image(systemName: currentTab != .vet ? "map" : "map.fill")
                }
                .tag(PetReminderTabs.vet)
            SettingsView(storeManager: storeManager)
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: currentTab != .settings ? "gearshape" : "gearshape.fill")
                }
                .tag(PetReminderTabs.settings)
        }
        .accentColor(.dynamicBlack)
        
        
    }
}

struct HomeManager_Previews: PreviewProvider{
    static var previews: some View{
        HomeManagerView(storeManager: StoreManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
