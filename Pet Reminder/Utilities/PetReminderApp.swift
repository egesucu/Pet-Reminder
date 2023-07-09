//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct PetReminderApp: App {

    @Environment(\.scenePhase) var scenePhase
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    @State private var cloudEnabled = false

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Pet.self, Feed.self, Vaccine.self])
                .tint(tintColor)
                .onAppear(perform: checkIcloud)
        }

    }

    func checkIcloud() {
        let container = CKContainer(identifier: "iCloud.com.softhion.Pet-Reminder")
        container.accountStatus(completionHandler: { status, error in
            if let error {
                print(error.localizedDescription)
            }
            switch status {
            case .couldNotDetermine:
                print("couldNotDetermine Errors")
            case .available:
                print("available Errors")
            case .restricted:
                print("restricted Errors")
            case .noAccount:
                print("noAccount Errors")
            case .temporarilyUnavailable:
                print("temporarilyUnavailable Errors")
            @unknown default:
                print("Unknown CloudKit Errors")
            }
        })
    }
}
