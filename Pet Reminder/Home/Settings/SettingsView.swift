//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    @StateObject var storeManager : StoreManager
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("App Settings")) {
                    NavigationLink("Change Pet Data", destination: PetListView().environment(\.managedObjectContext, viewContext))
                }
                Section {
                    NavigationLink("Donate") {
                        DonateView(storeManager: storeManager)
                    }
                } header: {
                    Text("Buy a 🫖")
                } footer: {
                    Text("© Ege Sucu \(Date.now.formatted(.dateTime.year()))")
                }
            }
            
            .navigationTitle(Text("Settings"))
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(storeManager: StoreManager())
    }
}
