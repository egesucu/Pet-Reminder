//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    @StateObject var storeManager : StoreManager
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text(Strings.appSettings)) {
                    NavigationLink(Strings.managePetTitle, destination: PetListView().environment(\.managedObjectContext, viewContext))
                    ColorPicker(Strings.settingsTintColor, selection: $tintColor)
                    NavigationLink(Strings.notificationsManageTitle, destination:
                        NotificationView().environment(\.managedObjectContext, viewContext))
                    NavigationLink(Strings.privacyPolicyTitle, destination: PrivacyPolicyView())
                }
                Section {
                    NavigationLink(Strings.donateUsTitle) {
                        DonateView(storeManager: storeManager)
                    }
                } header: {
                    Text(Strings.buyCoffeeTitle)
                } footer: {
                    Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
                }
            }
            
            .navigationTitle(Text(Strings.settingsTabTitle))
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(storeManager: StoreManager())
    }
}
