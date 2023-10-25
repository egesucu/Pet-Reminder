//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog

struct SettingsView: View {

    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    @State private var alertMessage: LocalizedStringKey = ""
    @State private var showAlert = false
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("app_settings")) {
                    NavigationLink(
                        "manage_pet_title",
                        destination: PetChangeListView()
                    )
                    ColorPicker(
                        "settings_tint_color",
                        selection: $tintColor
                    )
                    if tintColor != Color.accentColor {
                        Button {
                            tintColor = Color.accent
                            showAlert(content: "color_reset_cuccessfull")
                        } label: {
                            Text("settings_reset_color")
                        }
                        .sensoryFeedback(.success, trigger: showAlert)
                    }
                    NavigationLink(
                        "settings_change_icon",
                        destination: ChangeAppIconView()
                    )
                    NavigationLink(
                        "notifications_manage_title",
                        destination:
                            NotificationView()
                    )
                    NavigationLink(
                        "privacy_policy_title",
                        destination: PrivacyPolicyView()
                    )
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
        Button("remove_userdefaults", action: {
            let domainName = Bundle.main.bundleIdentifier ?? ""
            UserDefaults.standard.removePersistentDomain(forName: domainName)
            UserDefaults.standard.synchronize()
            Logger.settings.info("Hello Seen Debug: \(UserDefaults.standard.bool(forKey: "helloSeen"))")
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
        .environment(NotificationManager())
}
