//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct PetReminderApp: App {

    @Environment(\.scenePhase) var scenePhase
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Pet.self, Feed.self, Vaccine.self])
                .tint(tintColor)
        }

    }
}
