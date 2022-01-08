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
                    Text("Daily")
                }.tag(1)
            EventListView()
                .tabItem {
                    Image(systemName: currentTab != 2 ? "list.bullet" : "list.bullet.indent")
                    Text("Events")
                }.tag(2)
            FindVetView()
                .tabItem {
                    Image(systemName: currentTab != 3 ? "map" : "map.fill")
                    Text("Find Vet")
                }.tag(3)
            SettingsView(storeManager: storeManager).environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: currentTab != 4 ? "gearshape" : "gearshape.fill")
                    Text("Settings")
                }.tag(4)
        }
        .accentColor(Color(.label))
        
        
    }
}

struct HomeManager_Previews: PreviewProvider{
    static var previews: some View{
        HomeManagerView(storeManager: StoreManager())
            .previewDevice("iPhone 13 Pro Max")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
