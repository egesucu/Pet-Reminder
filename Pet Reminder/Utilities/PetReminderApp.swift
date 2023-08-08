//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

@main
struct PetReminderApp: App {

    @Environment(\.scenePhase) var scenePhase
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HelloView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
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
