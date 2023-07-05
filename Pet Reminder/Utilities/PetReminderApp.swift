//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2020.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct PetReminderApp: App {

    @Environment(\.scenePhase) var scenePhase
    var storeManager = StoreManager()
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some Scene {
        WindowGroup {
            MainView(storeManager: storeManager)
                .modelContainer(for: [Pet.self, Feed.self, Vaccine.self])
                .tint(tintColor)
                .onAppear {
                    storeManager.addManagerToPayment(manager: storeManager)
                    storeManager.getProducts()
                }

        }

    }
}
