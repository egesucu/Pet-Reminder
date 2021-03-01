//
//  Persistence.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import CoreData
import Foundation

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container : NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "PetReminder")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        }
        return container
    }()
    
    private init() {
       
    }
    public func saveContext(){
        
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
}
