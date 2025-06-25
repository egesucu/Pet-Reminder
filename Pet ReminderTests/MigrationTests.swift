
//
//  ModelTests.swift
//  Shared
//
//  Created by Ege Sucu on 26.06.2025.
//

import XCTest
@testable import Pet_Reminder
import Shared
import SwiftData

final class MigrationTests: XCTestCase {
    
    var url: URL!
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.url = FileManager.default.temporaryDirectory.appending(component: "default.store")
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Cleanup resources
        self.container = nil
        self.context = nil
        
        // Delete database
        try FileManager.default.removeItem(at: self.url)
        try? FileManager.default.removeItem(at: self.url.deletingPathExtension().appendingPathExtension("store-shm"))
        try? FileManager.default.removeItem(at: self.url.deletingPathExtension().appendingPathExtension("store-wal"))
    }
    
    func testMigrationV1toV2() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        // 1. Setup V1
        container = try setupModelContainer(for: PetSchemaV1.self, url: self.url)
        context = ModelContext(container)
        try loadSampleDataSchemaV1(context: context)
        let petsV1 = try context.fetch(FetchDescriptor<PetSchemaV1.Pet>())
        
        // 2. Migration V1 -> V2
        container = try setupModelContainer(for: PetSchemaV2.self, url: self.url)
        context = ModelContext(container)
        
        // 3. Assert: all animals should have extinct==false
        let pets = try context.fetch(FetchDescriptor<PetSchemaV2.Pet>())
        let viski = pets.first { $0.name == "Viski" }
        XCTAssertNotNil(viski, "Viski should be here.")
        XCTAssertEqual(viski?.feedSelection, .morning, "Viski needs to have both option selected as selection was nil & option defaults at 0.")
        
        let dino = pets.first { $0.name == "Dino" }
        XCTAssertNotNil(dino, "Dino should be here.")
        XCTAssertEqual(dino?.feedSelection, .evening, "Dino needs to have both option selected as the choice was 1")
        
        let leno = pets.first { $0.name == "Leno" }
        XCTAssertNotNil(leno, "Leno should be here.")
        XCTAssertEqual(leno?.feedSelection, .both, "Leno needs to have both option selected as the choice was 2")
        
        let jaylo = pets.first { $0.name == "Jaylo" }
        XCTAssertNotNil(jaylo, "Jaylo should be here.")
        XCTAssertEqual(jaylo?.feedSelection, .morning, "Jaylo needs to have morning option selected even when choice was 2")
        
        // 4. Rollback V2 -> V1
        container = try setupModelContainer(for: PetSchemaV1.self, url: self.url, rollback: true)
        context = ModelContext(container)
        
        // 5. Assert: there are the same number of animals as before the migration
        let petsV1Post = try context.fetch(FetchDescriptor<PetSchemaV1.Pet>())
        XCTAssertEqual(petsV1.count, petsV1Post.count, "Number of pets before and after migration and rollback are different.")
    }
    
    func loadSampleDataSchemaV1(context: ModelContext) throws {
        typealias Pet = PetSchemaV1.Pet
            
        let viski = Pet(
            birthday: .now,
            name: "Viski",
            createdAt: .now,
            feedSelection: nil,
            image: nil,
            feeds: nil,
            vaccines: nil,
            type: .dog
        )
        viski.choice = 0
        
        let dino = Pet(
            birthday: .now,
            name: "Dino",
            createdAt: .now,
            feedSelection: nil,
            image: nil,
            feeds: nil,
            vaccines: nil,
            type: .dog
        )
        dino.choice = 1
        
        let leno = Pet(
            birthday: .now,
            name: "Leno",
            createdAt: .now,
            feedSelection: nil,
            image: nil,
            feeds: nil,
            vaccines: nil,
            type: .dog
        )
        leno.choice = 2
        
        let jaylo = Pet(
            birthday: .now,
            name: "Jaylo",
            createdAt: .now,
            feedSelection: .morning,
            image: nil,
            feeds: nil,
            vaccines: nil,
            type: .dog
        )
        jaylo.choice = 2
        
        context.insert(viski)
        context.insert(dino)
        context.insert(leno)
        context.insert(jaylo)
        
        try context.save()
    }
}
