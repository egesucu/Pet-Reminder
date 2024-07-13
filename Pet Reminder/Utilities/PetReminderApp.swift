//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CloudKit
import SwiftData
import UI
import SharedModels

@main
struct PetReminderApp: App {

    @AppStorage(Strings.tintColor) var tintColor = ESColor(
        color: Color.accentColor
    )
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @Environment(\.undoManager) var undoManager
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            if helloSeen {
                HomeManagerView()
                    .environment(notificationManager)
                    .tint(tintColor.color)
            } else {
                HelloView()
                    .environment(notificationManager)
                    .tint(tintColor.color)
            }
        }
        .modelContainer(for: Pet.self)
    }
}
