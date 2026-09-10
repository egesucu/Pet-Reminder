import Foundation
import SwiftData
import Testing
import Shared
@testable import Pet_Reminder

@MainActor
@Suite("Pet data integrity")
struct PetDataIntegrityTests {

    @Test("Fresh pets accept their first feed and vaccine")
    func freshPetRelationships() throws {
        let pet = Pet(name: "Buddy")
        let feed = Feed(feedDate: .now, morningFed: true, morningFedStamp: .now)
        let vaccine = Vaccine(date: .now, name: "Rabies")

        pet.addFeed(feed)
        pet.addVaccine(vaccine)

        #expect(pet.feeds?.count == 1)
        #expect(pet.feeds?.first === feed)
        #expect(feed.pet === pet)
        #expect(pet.vaccines?.count == 1)
        #expect(pet.vaccines?.first === vaccine)
        #expect(vaccine.pet === pet)
    }

    @Test("Breed input is trimmed and empty input becomes nil")
    func breedNormalization() {
        let model = AddPet.Model()

        model.updateBreed(from: "  Golden Retriever  ")
        #expect(model.breed == "Golden Retriever")

        model.updateBreed(from: " \n ")
        #expect(model.breed == nil)
    }

    @Test("Version 1 stores migrate to the current schema")
    func versionOneStoreMigratesToCurrentSchema() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let storeURL = directory.appending(path: "PetReminder.store")

        do {
            let legacyConfiguration = ModelConfiguration(url: storeURL)
            let legacyContainer = try ModelContainer(
                for: PetSchemaV1.Pet.self,
                configurations: legacyConfiguration
            )
            let legacyPet = PetSchemaV1.Pet(
                birthday: Date(timeIntervalSince1970: 1_000_000),
                name: "Legacy",
                createdAt: Date(timeIntervalSince1970: 2_000_000),
                feedSelection: nil,
                kind: .cat
            )
            legacyPet.choice = 1
            legacyContainer.mainContext.insert(legacyPet)
            try legacyContainer.mainContext.save()
        }

        let currentConfiguration = ModelConfiguration(url: storeURL)
        let migrationPlan = PetMigrationPlan.self
        let currentContainer = try ModelContainer(
            for: Pet.self,
            migrationPlan: migrationPlan,
            configurations: currentConfiguration
        )
        let migratedPets = try currentContainer.mainContext.fetch(FetchDescriptor<Pet>())
        let migratedPet = try #require(migratedPets.first)

        #expect(migratedPets.count == 1)
        #expect(migratedPet.name == "Legacy")
        #expect(migratedPet.feedSelection == .evening)
        #expect(migratedPet.kind == .cat)
    }
}
