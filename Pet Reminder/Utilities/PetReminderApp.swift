//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData
import CloudKit

@main
struct PetReminderApp: App {

    @Environment(\.scenePhase) var scenePhase
    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    @AppStorage("seenHello") var helloSeen = false

    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            if helloSeen {
                HomeManagerView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tint(tintColor)
            } else {
                HelloView()
                    .environment(\.managedObjectContext, persistence.container.viewContext)
                    .tint(tintColor)
            }

        }
    }
}
