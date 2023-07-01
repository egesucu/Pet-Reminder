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
    var storeManager: StoreManager
//    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("app_settings")) {
                    NavigationLink(
                        "manage_pet_title",
                        destination: PetListView(
                        ).environment(
                            \.managedObjectContext,
                             viewContext
                        )
                    )
//                    ColorPicker("settings_tint_color", selection: $tintColor)
                    NavigationLink("notifications_manage_title", destination:
                        NotificationView().environment(\.managedObjectContext, viewContext))
                    NavigationLink("privacy_policy_title", destination: PrivacyPolicyView())
                }
                Section {
                    NavigationLink("donate_us_title") {
                        DonateView(storeManager: storeManager)
                    }
                } header: {
                    Text("buy_coffee_title")
                } footer: {
                    Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
                }
            }

            .navigationTitle(Text("settings_tab_title"))

        }.navigationViewStyle(.stack)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(storeManager: StoreManager())
    }
}
