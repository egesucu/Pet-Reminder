import Pets
import AppIntents
import CoreSpotlight
import Foundation
import Shared
import PetCare
import SwiftData
import Testing
@testable import Pet_Reminder

@MainActor
private final class MockPetSearchIndex: PetSearchIndex {
    var isAvailable = true
    var entities: [UUID: PetEntity] = [:]
    var indexCalls = 0
    var resetCalls = 0
    var removedIDs: [UUID] = []
    var failNextIndex = false
    var suspendNextIndex = false
    var pendingIndex: CheckedContinuation<Void, Never>?

    func index(_ pets: [PetEntity]) async throws {
        indexCalls += 1
        if failNextIndex {
            failNextIndex = false
            throw PetCareError.saveFailed
        }
        if suspendNextIndex {
            suspendNextIndex = false
            await withCheckedContinuation { pendingIndex = $0 }
        }
        for pet in pets { entities[pet.id] = pet }
    }

    func remove(ids: [UUID]) async throws {
        removedIDs.append(contentsOf: ids)
        for id in ids { entities.removeValue(forKey: id) }
    }

    func removeAllPets() async throws {
        resetCalls += 1
        entities.removeAll()
    }
}

@MainActor
struct PetSpotlightTests {
    private func container() throws -> ModelContainer {
        try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
    }

    private func defaults() throws -> (UserDefaults, String) {
        let suite = "PetSpotlightTests.\(UUID())"
        return (try #require(UserDefaults(suiteName: suite)), suite)
    }

    @Test("Pet metadata includes names, species, and breeds without duplicating feeding entities")
    func searchableAttributes() throws {
        let container = try container()
        let pet = Pet(name: "Luna", breed: "Beagle", kind: .dog)
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let snapshot = try #require(PetCareService(container: container).pets().first)
        let entity = PetEntity(snapshot)
        #expect(entity.id == pet.intentID)
        #expect(entity.attributeSet.title == "Luna")
        #expect(entity.attributeSet.keywords?.contains("Beagle") == true)
        #expect(entity.attributeSet.keywords?.contains(entity.animalType) == true)
        #expect(entity.attributeSet.contentDescription?.contains("Beagle") == true)
        #expect(!entity.hideInSpotlight)
    }

    @Test("Initial indexing and saved edits reconcile under the same UUID; no-op refreshes avoid writes")
    func savedEdits() async throws {
        let container = try container()
        let pet = Pet(name: "Luna", breed: "Beagle")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let (defaults, suite) = try defaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = MockPetSearchIndex()
        let service = PetCareService(container: container)
        let indexer = PetSpotlightIndexer(service: service, index: backend, defaults: defaults)
        try await indexer.refresh()
        let id = try #require(pet.intentID)
        #expect(backend.entities[id]?.name == "Luna")
        #expect(backend.resetCalls == 1)
        pet.name = "Unfinished name"
        try await indexer.refresh()
        #expect(backend.entities[id]?.name == "Luna")
        #expect(backend.indexCalls == 1)
        pet.name = "Renamed"
        pet.breed = "New breed"
        try container.mainContext.save()
        try await indexer.refresh()
        #expect(backend.entities[id]?.name == "Renamed")
        #expect(backend.entities[id]?.breed == "New breed")
        #expect(backend.entities.count == 1)
        #expect(backend.indexCalls == 2)
        try await indexer.refresh(force: true)
        #expect(backend.indexCalls == 3)
    }

    @Test("Deletion while the app is closed is removed using the persisted manifest")
    func deletionAcrossLaunches() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let id = try #require(pet.intentID)
        let (defaults, suite) = try defaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = MockPetSearchIndex()
        let service = PetCareService(container: container)
        try await PetSpotlightIndexer(service: service, index: backend, defaults: defaults).refresh()
        container.mainContext.delete(pet)
        try container.mainContext.save()
        try await PetSpotlightIndexer(service: service, index: backend, defaults: defaults).refresh()
        #expect(backend.entities.isEmpty)
        #expect(backend.removedIDs.contains(id))
        #expect(backend.resetCalls == 1)
    }

    @Test("An indexing failure is retryable; resetting preferences rebuilds instead of orphaning results")
    func failureAndReset() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let (defaults, suite) = try defaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = MockPetSearchIndex()
        backend.failNextIndex = true
        let indexer = PetSpotlightIndexer(service: PetCareService(container: container), index: backend, defaults: defaults)
        await #expect(throws: PetCareError.saveFailed) { try await indexer.refresh() }
        try await indexer.refresh()
        #expect(backend.entities.count == 1)
        defaults.removePersistentDomain(forName: suite)
        container.mainContext.delete(pet)
        try container.mainContext.save()
        try await indexer.refresh()
        #expect(backend.entities.isEmpty)
    }

    @Test("Partial system reindexing refreshes existing pets and removes deleted references")
    func partialReindex() async throws {
        let container = try container()
        let first = Pet(name: "Luna")
        let second = Pet(name: "Milo")
        container.mainContext.insert(first)
        container.mainContext.insert(second)
        try container.mainContext.save()
        let firstID = try #require(first.intentID)
        let secondID = try #require(second.intentID)
        let (defaults, suite) = try defaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = MockPetSearchIndex()
        let indexer = PetSpotlightIndexer(service: PetCareService(container: container), index: backend, defaults: defaults)
        try await indexer.refresh()
        first.name = "Renamed"
        container.mainContext.delete(second)
        try container.mainContext.save()
        try await indexer.reindex(ids: [firstID, secondID])
        #expect(backend.entities[firstID]?.name == "Renamed")
        #expect(backend.entities[secondID] == nil)
    }

    @Test("Unavailable indexing can resume later")
    func availability() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let (defaults, suite) = try defaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = MockPetSearchIndex()
        backend.isAvailable = false
        let indexer = PetSpotlightIndexer(service: PetCareService(container: container), index: backend, defaults: defaults)
        try await indexer.refresh()
        #expect(backend.indexCalls == 0)
        backend.isAvailable = true
        try await indexer.refresh()
        #expect(backend.entities.count == 1)
    }

    @Test("Overlapping refreshes cannot restore an older pet name over a newer save")
    func serializesRefreshes() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let id = try #require(pet.intentID)
        let (defaults, suite) = try defaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = MockPetSearchIndex()
        backend.suspendNextIndex = true
        let indexer = PetSpotlightIndexer(service: PetCareService(container: container), index: backend, defaults: defaults)
        let first = Task { try await indexer.refresh() }
        while backend.pendingIndex == nil { await Task.yield() }
        pet.name = "Renamed"
        try container.mainContext.save()
        let second = Task { try await indexer.refresh() }
        backend.pendingIndex?.resume()
        backend.pendingIndex = nil
        try await first.value
        try await second.value
        #expect(backend.entities[id]?.name == "Renamed")
    }
}
