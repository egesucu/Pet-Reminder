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
//    let persistence = PersistenceController.shared

    /// Previews are crashing with SwiftData  (see 111657477 ) and as of Beta 4,
    /// Apple recommends against #Preview with SwiftUI, so CoreData for now.
    /// https://developer.apple.com/documentation/xcode-release-notes/xcode-15-release-notes
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Pet.self, Feed.self, Vaccine.self])
                .tint(tintColor)
                .onAppear(perform: checkIcloud)
        }
    }
}

extension PetReminderApp {
    func checkIcloud() {
        DataManager.shared.checkIcloudAvailability { result in
            switch result {
            case .success:
                print("No Error")
            case .error(let icloudErrorType):
                switch icloudErrorType {
                case .icloudUnavailable:
                    print("Error: iCloud is not available")
                case .noIcloud:
                    print("Error: no iCloud found")
                case .restricted:
                    print("Error: Restricted")
                case .cantFetchStatus:
                    print("Error: Can't fetch Status")
                case .unknownError(let string):
                    print("Custom Error: \(string)")
                }
            }
        }
    }
}
