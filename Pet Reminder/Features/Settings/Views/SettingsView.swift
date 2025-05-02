//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import Shared


struct SettingsView: View {

    @State private var alertMessage: LocalizedStringKey = ""
    @State private var showAlert = false
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("app_settings")) {
                    NavigationLink {
                        PetChangeListView()
                            .environment(notificationManager)
                    } label: {
                        Text("manage_pet_title")
                    }
                    NavigationLink {
                        NotificationView()
                    } label: {
                        Text("notifications_manage_title")
                    }
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text(LocalizedStringKey("privacy_policy_title"))
                    }
                }
                Section {
                    NavigationLink {
                        DonateView()
                    } label: {
                        Text("donate_us_title")
                    }
                } header: {
                    Text("buy_coffee_title")
                } footer: {
                    Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
                }
                #if DEBUG
                debugMenu
                NavigationLink(
                    destination: AllNotificationsView()
                ) {
                    Text("All Notifications")
                }
                #endif
            }
            .alert(alertMessage, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}

            })
            .navigationTitle(Text("settings_tab_title"))
            .navigationBarTitleTextColor(.accent)

        }.navigationViewStyle(.stack)
    }

    private func showAlert(content: LocalizedStringKey) {
        alertMessage = content
        showAlert.toggle()
    }
}

#if DEBUG
private var debugMenu: some View {
    Section {
        Button {
            let domainName = Bundle.main.bundleIdentifier ?? ""
            UserDefaults.standard.removePersistentDomain(forName: domainName)
            UserDefaults.standard.synchronize()
            Logger.settings.info("Hello Seen Debug: \(UserDefaults.standard.bool(forKey: "helloSeen"))")
        } label: {
            Text("remove_userdefaults")
        }
    } header: {
        Text("debug_menu_title")
    } footer: {
        Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
    }
}
#endif

#Preview {
    SettingsView()
        .environment(NotificationManager())
}
