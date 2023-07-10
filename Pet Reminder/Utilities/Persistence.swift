//
//  Persistence.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.11.2020.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import CoreData
import Foundation
import CloudKit

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    func seeCloudKitStatus(with error: Error?, block: @escaping () -> Void) -> Error? {
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
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext
        context.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

        do {
            try context.save()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

}

extension PersistenceController {
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
            (0..<5).forEach { item in
                let feed = Feed(context: viewContext)
                let components = DateComponents(
                    year: Int.random(
                        in: 2018...2023
                    ),
                    month: Int.random(
                        in: 0...12
                    ),
                    day: Int.random(
                        in: 0...30
                    ),
                    hour: Int.random(
                        in: 0...23
                    ),
                    minute: Int.random(
                        in: 0...59
                    ),
                    second: Int.random(
                        in: 0...59
                    )
                )
                if item % 2 == 0 {
                    feed.morningFedStamp = Calendar.current.date(from: components)
                    feed.morningFed = true
                } else {
                    feed.eveningFedStamp = Calendar.current.date(from: components)
                    feed.eveningFed = true
                }
                demoPet.addToFeeds(feed)
            }
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
