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
    private enum Destination: String, Hashable {
        case managePets, notifications, privacyPolicy, donate
        #if DEBUG
        case allNotifications
        #endif
    }

    private let managePets: () -> AnyView
    @SceneStorage("settings.destination") private var storedDestination = ""
    private var selectedDestination: Destination? { Destination(rawValue: storedDestination) }
    private var selection: Binding<Destination?> {
        Binding(get: { selectedDestination }, set: { storedDestination = $0?.rawValue ?? "" })
    }

    public init(managePets: @escaping () -> AnyView) {
        self.managePets = managePets
    }

    public var body: some View {
        NavigationSplitView {
            List(selection: selection) {
                Section(header: Text(SharedStrings.appSettings)) {
                    sidebarLink(.managePets, title: SharedStrings.managePetTitle, systemImage: "pawprint")
                    sidebarLink(.notifications, title: SharedStrings.notificationsManageTitle, systemImage: "bell")
                    sidebarLink(.privacyPolicy, title: SharedStrings.privacyPolicyTitle, systemImage: "hand.raised")
                }
                Section {
                    sidebarLink(.donate, title: SharedStrings.donateUsTitle, systemImage: "cup.and.saucer")
                } header: {
                    Text(SharedStrings.buyCoffeeTitle)
                } footer: {
                    Text(currentYear)
                }
                #if DEBUG
                debugMenu
                #endif
            }
            .scrollContentBackground(.hidden)
            .background(Color.groupedBackground)
            .containerBackground(Color.groupedBackground, for: .navigation)
            .toolbarBackground(Color.groupedBackground, for: .navigationBar)
            .navigationTitle(Text(SharedStrings.settingsTabTitle))
            .navigationBarTitleDisplayMode(.large)
            .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 460)
        } detail: {
            NavigationStack {
                detail
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollContentBackground(.hidden)
                    .background(Color.groupedBackground)
                    .containerBackground(Color.groupedBackground, for: .navigation)
                    .toolbarBackground(Color.groupedBackground, for: .navigationBar)
            }
            .id(selectedDestination)
        }
        .navigationSplitViewStyle(.balanced)
        .containerBackground(Color.groupedBackground, for: .navigationSplitView)
        .background(Color.groupedBackground.ignoresSafeArea())
        .toolbarBackground(Color.groupedBackground, for: .tabBar)
    }

    private func sidebarLink(
        _ destination: Destination,
        title: LocalizedStringResource,
        systemImage: String
    ) -> some View {
        NavigationLink(value: destination) {
            Label { Text(title) } icon: { Image(systemName: systemImage) }
        }
    }

    @ViewBuilder private var detail: some View {
        switch selectedDestination {
        case .managePets:
            managePets()
        case .notifications:
            Notifications()
        case .privacyPolicy:
            PrivacyPolicy()
        case .donate:
            Donate()
        #if DEBUG
        case .allNotifications:
            AllNotifications()
                .navigationTitle(Text(SharedStrings.allNotifications))
        #endif
        case nil:
            ContentUnavailableView {
                Label { Text(SharedStrings.settingsTabTitle) } icon: { Image(systemName: "gearshape") }
            }
        }
    }

    /// Shows the current year info from latest year
    /// - Returns: A String value depending on the current year,
    /// like `© Ege Sucu 2025`
    var currentYear: String {
        Strings.footerLabel(Date.now.formatted(.dateTime.year()))
    }

#if DEBUG
    private var debugMenu: some View {
        Section {
            Button(SharedStrings.removeUserdefaults, action: removeUserDefaults)
            sidebarLink(.allNotifications, title: SharedStrings.allNotifications, systemImage: "bell.badge")
        } header: {
            Text(SharedStrings.debugMenuTitle)
        }
    }
#endif
}

#if DEBUG
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
