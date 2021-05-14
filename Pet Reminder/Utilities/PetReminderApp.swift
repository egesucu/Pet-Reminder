//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

@main
struct PetReminderApp: App {
    
    
    let context = PersistenceController.shared.container.viewContext
    let petSaved = UserDefaults.standard.bool(forKey: "petAvailable")
 
    var body: some Scene {
        WindowGroup {
            
            
            if petSaved{
                HomeManagerView().environment(\.managedObjectContext, context)
            } else {
                HelloView().environment(\.managedObjectContext, context)
            }
            

        }
    }
    
    
    
}

