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
    
    let isPetSaved = UserDefaults.standard.bool(forKey: "petSaved")
    
    @FetchRequest(sortDescriptors: [])
    var pets : FetchedResults<Pet>
   
    var body: some Scene {
        WindowGroup {
                if (isPetSaved){
                    HomeView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    HelloView().environment(\.managedObjectContext, persistenceController.container.viewContext)  
                }
            
            
        }
    }
}

