//
//  Persistence.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.11.2020.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import CoreData
import UIKit
import CloudKit

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PetReminder")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // Generate NOTIFICATIONS on remote changes
        container.persistentStoreDescriptions.forEach {
            $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            $0.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        container.viewContext.automaticallyMergesChangesFromParent = true

        do {
            try container.initializeCloudKitSchema()
        } catch let error {
            print(error.localizedDescription)
        }
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

// MARK: Creating Demo Data
extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        (0..<10).forEach { _ in
            createRandomPet(viewContext)
        }
        PersistenceController.shared.save()
        return result
    }()

    static func createRandomPet(_ viewContext: NSManagedObjectContext) {
        let pet = Pet(context: viewContext)
        pet.name = ["Viski", "Doggy", "Blurry", "Vury"].randomElement()
        pet.id = UUID()
        let defaultImage = UIImage(resource: ImageResource.defaultAnimal)
        pet.image = defaultImage.jpegData(compressionQuality: 0.8)
        (0..<5).forEach { item in
            addFeed(viewContext, pet: pet, item: item)
        }
        (0..<2).forEach { _ in
           addVaccine(viewContext, pet: pet)
        }
    }

    static func addFeed(_ viewContext: NSManagedObjectContext, pet: Pet, item: Int) {
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
        pet.addToFeeds(feed)
    }

    static func addVaccine(_ viewContext: NSManagedObjectContext, pet: Pet) {
        let vaccine = Vaccine(context: viewContext)
        vaccine.name = ["Pulvarin", "Silverdin", "Bulidin"].randomElement()
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
        vaccine.date = Calendar.current.date(from: components)
        pet.addToVaccines(vaccine)
    }
}
