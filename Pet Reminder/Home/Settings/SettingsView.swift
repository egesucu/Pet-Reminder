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
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("App Settings")) {
                    NavigationLink("Pets", destination: PetListView().environment(\.managedObjectContext, viewContext))
                }

            }
            
            .navigationTitle(Text("Settings"))
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
