//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var accentColor = Color.accentColor
    
    
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Account Info")) {
                    Text("Demo")
                }
                
                Section(header: Text("App Settings")) {
                    NavigationLink("Pets", destination: Text("Hi"))
                    ColorPicker("Accent Color", selection: $accentColor)
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
