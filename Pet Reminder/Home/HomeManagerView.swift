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
    @State private var currentTab = 1
    @StateObject var storeManager : StoreManager
    
    var body: some View {
        
        
        TabView(selection: $currentTab) {
            HomeView().environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: currentTab != 1 ? "person.crop.circle" : "person.crop.circle.fill")
                    Text("home_tab_title")
                }.tag(1)
            EventListView()
                .tabItem {
                    Image(systemName: currentTab != 2 ? "list.bullet" : "list.bullet.indent")
                    Text("event_tab_title")
                }.tag(2)
            FindVetView()
                .tabItem {
                    Image(systemName: currentTab != 3 ? "map" : "map.fill")
                    Text("find_vet_title")
                }.tag(3)
            SettingsView(storeManager: storeManager).environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: currentTab != 4 ? "gearshape" : "gearshape.fill")
                    Text("settings_tab_title")
                }.tag(4)
        }
        .accentColor(Color(.label))
        
        
    }
}

struct HomeManager_Previews: PreviewProvider{
    static var previews: some View{
        HomeManagerView(storeManager: StoreManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
