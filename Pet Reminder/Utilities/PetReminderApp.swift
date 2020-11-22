//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

@main
struct PetReminderApp: App {
   
    let persistenceController = PersistenceController.shared
    
   
    var body: some Scene {
        WindowGroup {
            HelloView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

