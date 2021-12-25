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
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject var storeManager = StoreManager()
    let controller = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView(storeManager: storeManager)
                .environment(\.managedObjectContext, controller.container.viewContext)
                .accentColor(.green)
                .onAppear {
                    storeManager.addManagerToPayment(manager: storeManager)
                    storeManager.getProducts()
                }
            
        }.onChange(of: scenePhase) { _ in
            controller.save()
        }
        
    }
}

