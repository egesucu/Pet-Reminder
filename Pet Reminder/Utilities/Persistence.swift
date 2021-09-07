//
//  Persistence.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import CoreData
import Foundation
import CloudKit

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let demoPet = Pet(context: viewContext)
            demoPet.name = "Viski"
            demoPet.id = UUID()
            demoPet.image = nil
            demoPet.selection = .both
            demoPet.birthday = Date()
            demoPet.morningFed = false
            demoPet.morningTime = Date()
            demoPet.eveningFed = false
            demoPet.eveningTime = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    
    
    let container: NSPersistentCloudKitContainer
    
    
    func seeCloudKitStatus(with error: Error?, block: @escaping () -> ()) -> Error?{
        guard let effectiveError = error as? CKError else {
            return error
        }
        
        guard let retryAfter = effectiveError.retryAfterSeconds else {
            return effectiveError
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + retryAfter) {
            block()
        }
        
        return nil
        
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PetReminder")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func save(){
        let context = container.viewContext
        context.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        
        do {
            try context.save()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    

}
