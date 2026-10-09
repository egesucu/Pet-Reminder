import Foundation
import Shared
import SwiftData
import Testing

@MainActor
struct PetCareServiceTests {
    @Test("A feeding session refresh shows intent saves without changing the UI editing context")
    func displayedModelUpdates() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let id = try #require(pet.intentID)
        let session = PetCareSession(container: container)
        try session.reload(id: id)
        #expect(session.pet?.feeds?.isEmpty != false)
        pet.breed = "Unfinished edit"
        let service = PetCareService(container: container)
        let revision = service.revision
        _ = try service.markFed(id: id, meal: .morning)
        #expect(service.revision != revision)
        try session.reload(id: id)
        let refreshed = try #require(session.pet)
        #expect(DailyFeeds.isFed(.morning, pet: refreshed, at: .now))
        #expect(refreshed.feeds?.first?.morningFedStamp != nil)
        #expect(pet.breed == "Unfinished edit")
        #expect(container.mainContext.hasChanges)
    }
    private func container() throws -> ModelContainer {
        try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
    }

    @Test("Imported missing IDs are persisted once, including ambiguous names")
    func identityAndSearch() throws {
        let container = try container()
        for name in ["Lúna", "Luna", "Milo"] {
            let pet = Pet(name: name)
            pet.intentID = nil
            container.mainContext.insert(pet)
        }
        try container.mainContext.save()
        let service = PetCareService(container: container)
        let first = try service.pets(matching: "  LUNA ")
        #expect(first.count == 2)
        #expect(Set(first.map(\.id)).count == 2)
        #expect(try service.pets(matching: "luna").map(\.id) == first.map(\.id))
        #expect(try service.pets(for: first.map(\.id)).count == 2)
        let context = ModelContext(container)
        #expect(try context.fetch(FetchDescriptor<Pet>()).allSatisfy { $0.intentID != nil })
    }

    @Test("Failed ID backfill exposes no temporary identity and can be retried")
    func failedIdentityBackfill() throws {
        let container = try container()
        let pet = Pet(name: "Legacy")
        pet.intentID = nil
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let failing = PetCareService(container: container, save: { _ in throw PetCareError.saveFailed })
        #expect(throws: PetCareError.saveFailed) { try failing.pets() }
        let readContext = ModelContext(container)
        #expect(try readContext.fetch(FetchDescriptor<Pet>()).first?.intentID == nil)
        let service = PetCareService(container: container)
        let first = try service.pets()
        #expect(first.count == 1)
        #expect(try service.pets().first?.id == first.first?.id)
    }

    @Test("A legacy completion without a timestamp is not treated as a new meal")
    func legacyCompletion() throws {
        let container = try container()
        let pet = Pet(name: "Legacy")
        container.mainContext.insert(pet)
        let now = Date.now
        pet.addFeed(Feed(feedDate: now, morningFed: true))
        pet.addFeed(Feed(feedDate: now, morningFed: false, morningFedStamp: now.addingTimeInterval(-60)))
        try container.mainContext.save()
        let service = PetCareService(container: container, clock: { now })
        let result = try service.markFed(id: #require(pet.intentID), meal: .morning)
        #expect(result.morningFed)
        #expect(result.morningTime == nil)
    }

    @Test("Recording is idempotent and reconciles synced duplicates without changing the other meal")
    func repeatedMeals() throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        let date = Date(timeIntervalSince1970: 1_780_000_000)
        let earlier = date.addingTimeInterval(-60)
        pet.addFeed(Feed(feedDate: date, morningFed: true, morningFedStamp: earlier))
        pet.addFeed(Feed(eveningFed: true, eveningFedStamp: earlier, feedDate: date))
        try container.mainContext.save()
        let service = PetCareService(container: container, clock: { date })
        let id = try #require(pet.intentID)
        let first = try service.markFed(id: id, meal: .morning)
        let second = try service.markFed(id: id, meal: .morning)
        #expect(first.morningTime == earlier)
        #expect(second.morningTime == earlier)
        #expect(second.eveningTime == earlier)
        let context = ModelContext(container)
        let saved = try #require(context.fetch(FetchDescriptor<Pet>()).first)
        #expect(saved.feeds?.count == 2)
        #expect(saved.feeds?.allSatisfy { $0.morningFed } == true)
    }

    @Test("Intent contexts never commit unsaved UI changes")
    func isolatesUIEdits() throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let id = try #require(pet.intentID)
        pet.name = "Unfinished edit"
        let service = PetCareService(container: container)
        let status = try service.markFed(id: id, meal: .evening)
        #expect(status.pet.name == "Luna")
        #expect(container.mainContext.hasChanges)
        #expect(pet.name == "Unfinished edit")
        #expect(try service.feedingStatus(id: id).eveningFed)
    }

    @Test("A failed save rolls back feeding and preserves unfinished UI edits")
    func failedSave() throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        pet.breed = "Unfinished"
        let service = PetCareService(container: container, save: { _ in throw PetCareError.saveFailed })
        #expect(throws: PetCareError.saveFailed) {
            try service.markFed(id: try #require(pet.intentID), meal: .morning)
        }
        #expect(pet.breed == "Unfinished")
        #expect(try !PetCareService(container: container).feedingStatus(id: #require(pet.intentID)).morningFed)
    }

    @Test("Unscheduled meals, both meals, and deleted references fail without writing")
    func invalidRequests() throws {
        let container = try container()
        let pet = Pet(name: "Luna", feedSelection: .morning)
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let service = PetCareService(container: container)
        let id = try #require(pet.intentID)
        #expect(throws: PetCareError.unsupportedMeal) { try service.markFed(id: id, meal: .evening) }
        #expect(throws: PetCareError.unsupportedMeal) { try service.markFed(id: id, meal: .both) }
        container.mainContext.delete(pet)
        try container.mainContext.save()
        #expect(try service.pets(for: [id]).isEmpty)
        #expect(throws: PetCareError.petNotFound) { try service.feedingStatus(id: id) }
    }

    @Test("Today follows local calendar boundaries, including daylight saving and zone changes")
    func calendarBoundaries() throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let morning = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 8)))
        var now = morning
        let service = PetCareService(container: container, clock: { now }, calendar: { calendar })
        let id = try #require(pet.intentID)
        _ = try service.markFed(id: id, meal: .morning)
        #expect(try service.feedingStatus(id: id).morningFed)
        now = try #require(calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: morning)))
        #expect(try !service.feedingStatus(id: id).morningFed)
        now = morning
        calendar.timeZone = try #require(TimeZone(identifier: "Pacific/Honolulu"))
        #expect(try service.feedingStatus(id: id).day == calendar.startOfDay(for: now))
    }
}
