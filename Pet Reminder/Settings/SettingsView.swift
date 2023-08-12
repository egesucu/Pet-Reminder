//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData
import OSLog

struct SettingsView: View {

    @Environment(\.managedObjectContext)
    private var viewContext
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

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
                #if DEBUG
                debugMenu
                #endif
            }

            .navigationTitle(Text("settings_tab_title"))

        }.navigationViewStyle(.stack)
    }
}

#if DEBUG
private var debugMenu: some View {
    Section {
        Button("remove_userdefaults", action: {
            let domainName = Bundle.main.bundleIdentifier ?? ""
            UserDefaults.standard.removePersistentDomain(forName: domainName)
            UserDefaults.standard.synchronize()
            Logger.viewCycle.notice("App crashed for resetting UserDefaults.")
            Logger.viewCycle.info("Hello Seen Debug: \(UserDefaults.standard.bool(forKey: "helloSeen"))")
            //assert(false)
        })
    } header: {
        Text("debug_menu_title")
    } footer: {
        Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
    }
}
#endif


#Preview {
    SettingsView()
}
