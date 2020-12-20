//
//  Persistence.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container : NSPersistentCloudKitContainer
    
    init() {
        container = NSPersistentCloudKitContainer(name: "PetReminder")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("An error occured with the code: \(error.code) and title :\(error.userInfo)")
                
            }
        }
    }
    
    
}
