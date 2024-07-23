//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import SharedModels

public struct SettingsView: View {

    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)
    @State private var alertMessage: LocalizedStringKey = ""
    @State private var showAlert = false
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("app_settings", bundle: .module)) {
                    NavigationLink {
                        PetChangeListView()
                    } label: {
                        Text("manage_pet_title", bundle: .module)
                    }
                    ColorPicker(selection: $tintColor.color) {
                        Text("settings_tint_color", bundle: .module)
                    }
                    if tintColor != ESColor(color: Color.accentColor) {
                        Button {
                            tintColor = ESColor(color: Color.accentColor)
                            showAlert(content: "color_reset_cuccessfull")
                        } label: {
                            Text(LocalizedStringKey("settings_reset_color"))
                        }
                        .sensoryFeedback(.success, trigger: showAlert)
                    }
                    NavigationLink {
                        NotificationView()
                    } label: {
                        Text("notifications_manage_title", bundle: .module)
                    }
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text(LocalizedStringKey("privacy_policy_title"), bundle: .module)
                    }
                }
                Section {
                    NavigationLink {
                        DonateView()
                    } label: {
                        Text("donate_us_title", bundle: .module)
                    }
                } header: {
                    Text("buy_coffee_title", bundle: .module)
                } footer: {
                    Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
                }
                #if DEBUG
                debugMenu
                NavigationLink(
                    destination: AllNotificationsView()
                ) {
                    Text("All Notifications", bundle: .module)
                }
                #endif
            }
            .alert(alertMessage, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}

            })
            .navigationTitle(Text("settings_tab_title", bundle: .module))

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
            Text("remove_userdefaults", bundle: .module)
        }
    } header: {
        Text("debug_menu_title", bundle: .module)
    } footer: {
        Text(Strings.footerLabel(Date.now.formatted(.dateTime.year())))
    }
}
#endif

#Preview {
    SettingsView()
        .environment(NotificationManager())
}
