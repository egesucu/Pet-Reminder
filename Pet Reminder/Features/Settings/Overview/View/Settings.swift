//
//  Settings.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import Shared

struct Settings: View {
    @Environment(\.notification) private var notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(.appSettings)) {
                    NavigationLink(.managePetTitle) {
                        PetChangeList()
                            .notification(notificationManager)
                    }
                    NavigationLink(.notificationsManageTitle) {
                        Notifications()
                    }
                    NavigationLink(.privacyPolicyTitle) {
                        PrivacyPolicy()
                    }
                }
                Section {
                    NavigationLink(.donateUsTitle) {
                        Donate()
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
            AllNotifications()
        }
    } header: {
        Text(.debugMenuTitle)
    }
}

private func removeUserDefaults() {
    Logger.settings.debug("Removing the user defaults")
    let domainName = Bundle.main.bundleIdentifier ?? .empty
    Logger.settings.debug("Bundle ID is: \(domainName)")
    UserDefaults.standard.removePersistentDomain(forName: domainName)
    UserDefaults.standard.synchronize()
    Logger.settings.info("Hello Seen Debug: \(UserDefaults.standard.bool(forKey: "helloSeen"))")
}

#Preview {
    Settings()
        .notification(NotificationManager.shared)
}
#endif
