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
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(.appSettings)) {
                    NavigationLink(.managePetTitle) {
                        PetChangeListView()
                            .environment(notificationManager)
                    }
                    NavigationLink(.notificationsManageTitle) {
                        NotificationView()
                    }
                    NavigationLink(.privacyPolicyTitle) {
                        PrivacyPolicyView()
                    }
                    NavigationLink(.licenseViewLabel) {
                        LicenseView()
                    }
                }
                Section {
                    NavigationLink(.donateUsTitle) {
                        DonateView()
                    }
                } header: {
                    Text(.buyCoffeeTitle)
                } footer: {
                    Text(currentYear)
                }
                #if DEBUG
                debugMenu
                #endif
            }
            .navigationTitle(Text(.settingsTabTitle))
            .navigationBarTitleTextColor(.accent)
        }
    }

    /// Shows the current year info from latest year
    /// - Returns: A String value depending on the current year,
    /// like `© Ege Sucu 2025`
    var currentYear: String {
        Strings.footerLabel(Date.now.formatted(.dateTime.year()))
    }
}

#if DEBUG
private var debugMenu: some View {
    Section {
        Button(.removeUserdefaults, action: removeUserDefaults)
        NavigationLink(.allNotifications) {
            AllNotificationsView()
        }
    } header: {
        Text(.debugMenuTitle)
    }
}

private func removeUserDefaults() {
    Logger.settings.debug("Removing the user defaults")
    let domainName = Bundle.main.bundleIdentifier ?? ""
    Logger.settings.debug("Bundle ID is: \(domainName)")
    UserDefaults.standard.removePersistentDomain(forName: domainName)
    UserDefaults.standard.synchronize()
    Logger.settings.info("Hello Seen Debug: \(UserDefaults.standard.bool(forKey: "helloSeen"))")
}

#endif

#Preview {
    SettingsView()
        .environment(NotificationManager.shared)
}
