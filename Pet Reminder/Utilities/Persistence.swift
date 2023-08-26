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

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<20 {
            let demoPet = Pet(context: viewContext)
            demoPet.name = Strings.demoPets[safe: index] ?? "-"
            demoPet.id = UUID()
            demoPet.image = nil
            demoPet.selection = .both
            demoPet.birthday = Date()
            for index in 0..<5 {
                let feed = Feed(context: viewContext)

                if index % 2 == 0 {
                    feed.morningFedStamp = .randomDate()
                    feed.morningFed = true
                } else {
                    feed.eveningFedStamp = .randomDate()
                    feed.eveningFed = true
                }
                demoPet.addToFeeds(feed)

                let vaccine = Vaccine(context: viewContext)
                vaccine.date = .randomDate()
                vaccine.name = Strings.demoVaccines.randomElement() ?? ""
                demoPet.addToVaccines(vaccine)
            }
        }
        do {
            try viewContext.save()
        } catch let error {
            fatalError("Unresolved error: \(error.localizedDescription)")
        }
        return result
    }()

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

        do {
            try context.save()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

}
