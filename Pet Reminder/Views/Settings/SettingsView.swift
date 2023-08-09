//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct SettingsView: View {

    @Environment(\.managedObjectContext)
    private var viewContext
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("app_settings")) {
                    NavigationLink(
                        "manage_pet_title",
                        destination: PetListView(reference: .settings)
                            .environment(\.managedObjectContext, viewContext)
                    )
                    ColorPicker("settings_tint_color", selection: $tintColor)
                    NavigationLink("notifications_manage_title", destination:
                        NotificationView().environment(\.managedObjectContext, viewContext))
                    NavigationLink("privacy_policy_title", destination: PrivacyPolicyView())
                }
                Section {
                    NavigationLink("donate_us_title") {
                        DonateView()
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

#Preview {
    SettingsView()
}
