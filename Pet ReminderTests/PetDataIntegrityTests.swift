import Foundation
import SwiftData
import Testing
import Shared
@testable import Pet_Reminder

private final class MigrationFixtureBundle: NSObject {}

@MainActor
@Suite("Pet data integrity")
struct PetDataIntegrityTests {
    @Test("The original shipped V4 store migrates with its feeding and vaccine relationships intact")
    func shippedVersionFourStore() throws {
        let fixture = try #require(Bundle(for: MigrationFixtureBundle.self).url(forResource: "OriginalV4", withExtension: "store"))
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let destination = directory.appending(path: "Migrated.store")
        try FileManager.default.copyItem(at: fixture, to: destination)
        let container = try ModelContainer(
            for: Pet.self, migrationPlan: PetMigrationPlan.self,
            configurations: ModelConfiguration(url: destination, cloudKitDatabase: .none)
        )
        let pets = try container.mainContext.fetch(FetchDescriptor<Pet>())
        let pet = try #require(pets.first)
        #expect(pets.count == 1)
        #expect(pet.intentID != nil)
        #expect(pet.name == "Shipped V4")
        #expect(pet.breed == "Beagle")
        #expect(pet.feeds?.first?.morningFed == true)
        #expect(pet.feeds?.first?.pet === pet)
        #expect(pet.vaccines?.first?.name == "Rabies")
        #expect(pet.vaccines?.first?.pet === pet)
    }

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

    @Test("Version 4 migration preserves relationships and gives distinct durable IDs")
    func versionFourIdentityMigration() throws {
        let storeURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID()).store")
        let configuration = ModelConfiguration(url: storeURL, cloudKitDatabase: .none)
        do {
            let container = try ModelContainer(for: PetSchemaV4.Pet.self, configurations: configuration)
            let first = PetSchemaV4.Pet(name: "Luna", breed: "Beagle", kind: .dog)
            let second = PetSchemaV4.Pet(name: "Milo", feedSelection: .evening, kind: .cat)
            first.feeds = [PetSchemaV4.Feed(feedDate: .now, morningFed: true, morningFedStamp: .now)]
            first.vaccines = [PetSchemaV4.Vaccine(name: "Rabies")]
            container.mainContext.insert(first)
            container.mainContext.insert(second)
            try container.mainContext.save()
        }
        var savedIDs: [UUID] = []
        do {
            let container = try ModelContainer(for: Pet.self, migrationPlan: PetMigrationPlan.self, configurations: configuration)
            let pets = try container.mainContext.fetch(FetchDescriptor<Pet>(sortBy: [.init(\.name)]))
            #expect(pets.count == 2)
            savedIDs = try pets.map { try #require($0.intentID) }
            #expect(Set(savedIDs).count == 2)
            let luna = try #require(pets.first)
            #expect(luna.breed == "Beagle")
            #expect(luna.feeds?.first?.morningFed == true)
            #expect(luna.feeds?.first?.pet === luna)
            #expect(luna.vaccines?.first?.name == "Rabies")
            #expect(luna.vaccines?.first?.pet === luna)
            #expect(pets.last?.feedSelection == .evening)
            luna.name = "Renamed"
            try container.mainContext.save()
        }
        let reopened = try ModelContainer(for: Pet.self, migrationPlan: PetMigrationPlan.self, configurations: configuration)
        let ids = try reopened.mainContext.fetch(FetchDescriptor<Pet>()).compactMap(\.intentID)
        #expect(Set(ids) == Set(savedIDs))
    }

}
