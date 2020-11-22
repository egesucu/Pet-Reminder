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
    
    static var preview: PersistenceController = {
        
        let result = PersistenceController(inMemory : true)
        let viewContext = result.container.viewContext
        
        for _ in 1..<10 {
            let newItem = Pet(context: viewContext)
            newItem.name = "Whiskey"
            newItem.birthday = Date()
            newItem.eveningFed = true
            newItem.morningFed = false
            newItem.id = UUID()
            newItem.morningTime = Date()
            newItem.eveningTime = Date()
            newItem.image = Data()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("An error occured with \(nsError) and info :\(nsError.userInfo)")
        }
        
        
        return result
        
    }()
    
    let container : NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PetReminder")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("An error occured with the code: \(error.code) and title :\(error.userInfo)")
                
            }
        }
    }
    
    
    
}
