//
//  RootView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    
    var body: some View {
        
        
        TabView {
            HomeView().environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Daily")
                }
            EventsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Events")
                }
            FindVetView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Find Vet")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .font(.headline)
        
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
