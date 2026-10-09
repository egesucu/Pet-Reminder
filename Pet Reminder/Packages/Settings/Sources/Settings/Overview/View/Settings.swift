//
//  Settings.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Reminders
import SwiftUI
import OSLog
import Shared
import SharedUI

@MainActor
public struct Settings: View {
    private let managePets: () -> AnyView

    public init(managePets: @escaping () -> AnyView) {
        self.managePets = managePets
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(SharedStrings.appSettings)) {
                    NavigationLink(SharedStrings.managePetTitle) {
                        managePets()
                    }
                    NavigationLink(SharedStrings.notificationsManageTitle) {
                        Notifications()
                    }
                    NavigationLink(SharedStrings.privacyPolicyTitle) {
                        PrivacyPolicy()
                    }
                }
                Section {
                    NavigationLink(SharedStrings.donateUsTitle) {
                        Donate()
                    }
                } header: {
                    Text(SharedStrings.buyCoffeeTitle)
                } footer: {
                    Text(currentYear)
                }
                #if DEBUG
                debugMenu
                #endif
            }
            .navigationTitle(Text(SharedStrings.settingsTabTitle))
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
        Button(SharedStrings.removeUserdefaults, action: removeUserDefaults)
        NavigationLink(SharedStrings.allNotifications) {
            AllNotifications()
        }
    } header: {
        Text(SharedStrings.debugMenuTitle)
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
    Settings(managePets: { AnyView(Text(SharedStrings.managePetTitle)) })
        .notification(NotificationManager())
}
#endif
