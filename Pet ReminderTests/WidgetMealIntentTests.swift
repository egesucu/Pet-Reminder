import AppIntents
import Foundation
import PetCare
import Shared
import SwiftData
import Testing
@testable import Pet_Reminder

@MainActor
struct WidgetMealIntentTests {
    private func withAction(
        at date: Date = .now,
        failingSave: Bool = false,
        operation: (ModelContainer, PetCareService, WidgetSnapshotStore, WidgetFeedingAction) async throws -> Void
    ) async throws {
        let container = try ModelContainer(for: Pet.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WidgetSnapshotStore(directory: directory)
        let service = PetCareService(container: container, clock: { date }, save: { context in
            if failingSave { throw PetCareError.saveFailed }
            try context.save()
        })
        let publisher = PetWidgetPublisher(container: container, service: service, store: store)
        try await operation(container, service, store, publisher.feedingAction(clock: { date }))
    }

    @Test("Widget toggles save and undo meals, isolate UI edits, and publish before returning")
    func recordMeals() async throws {
        let date = Date.now
        try await withAction(at: date) { container, service, store, action in
            let pet = Pet(name: "Fishi", kind: .fish)
            container.mainContext.insert(pet)
            try container.mainContext.save()
            let id = try #require(pet.intentID)
            pet.name = "Unfinished edit"
            let morning = ToggleWidgetMealIntent(petID: id, meal: .morning, day: date, expectedFed: false)
            morning.action = action
            _ = try await morning.perform()
            let first = try service.feedingStatus(id: id)
            #expect(first.morningFed)
            #expect(!first.eveningFed)
            #expect(store.read()?.pets.first?.morningFed == true)
            #expect(store.read()?.pets.first?.name == "Fishi")
            #expect(pet.name == "Unfinished edit")
            #expect(container.mainContext.hasChanges)
            _ = try await morning.perform()
            #expect(try service.feedingStatus(id: id).morningFed)
            #expect(store.read()?.pets.first?.morningFed == true)
            let undo = ToggleWidgetMealIntent(petID: id, meal: .morning, day: date, expectedFed: true)
            undo.action = action
            _ = try await undo.perform()
            let undone = try service.feedingStatus(id: id)
            #expect(!undone.morningFed)
            #expect(undone.morningTime == nil)
            #expect(store.read()?.pets.first?.morningFed == false)
            _ = try await morning.perform()
            #expect(try service.feedingStatus(id: id).morningFed)
            let evening = ToggleWidgetMealIntent(petID: id, meal: .evening, day: date)
            evening.action = action
            _ = try await evening.perform()
            #expect(store.read()?.pets.first?.completed == 2)
            let saved = ModelContext(container)
            #expect(try saved.fetch(FetchDescriptor<Feed>()).count == 1)
        }
    }

    @Test("A stale toggle from yesterday refreshes today's data without changing a meal")
    func staleDay() async throws {
        let date = Date.now
        let yesterday = try #require(Calendar.current.date(byAdding: .day, value: -1, to: date))
        try await withAction(at: date) { container, service, store, action in
            let pet = Pet(name: "Luna")
            container.mainContext.insert(pet)
            try container.mainContext.save()
            let id = try #require(pet.intentID)
            let intent = ToggleWidgetMealIntent(petID: id, meal: .morning, day: yesterday)
            intent.action = action
            _ = try await intent.perform()
            #expect(try !service.feedingStatus(id: id).morningFed)
            #expect(store.read()?.date == date)
            #expect(store.read()?.pets.first?.completed == 0)
        }
    }

    @Test("Changed schedules and deleted pets reconcile the widget without recording invalid meals")
    func changedPet() async throws {
        let date = Date.now
        try await withAction(at: date) { container, service, store, action in
            let pet = Pet(name: "Luna", feedSelection: .evening)
            container.mainContext.insert(pet)
            try container.mainContext.save()
            let id = try #require(pet.intentID)
            let intent = ToggleWidgetMealIntent(petID: id, meal: .morning, day: date)
            intent.action = action
            #expect(throws: PetIntentError.unsupportedMeal) {
                try action.toggle(id: id, meal: .morning, displayedDay: date)
            }
            await #expect(throws: PetIntentError.unsupportedMeal) {
                try await intent.perform()
            }
            #expect(try !service.feedingStatus(id: id).morningFed)
            #expect(store.read()?.pets.first?.morningScheduled == false)
            container.mainContext.delete(pet)
            try container.mainContext.save()
            #expect(throws: PetIntentError.missingPet) {
                try action.toggle(id: id, meal: .morning, displayedDay: date)
            }
            await #expect(throws: PetIntentError.missingPet) {
                try await intent.perform()
            }
            #expect(store.read()?.pets.isEmpty == true)
        }
    }

    @Test("Failed widget saves roll back and never publish a completed meal")
    func failedSave() async throws {
        let date = Date.now
        try await withAction(at: date, failingSave: true) { container, _, store, action in
            let pet = Pet(name: "Luna")
            container.mainContext.insert(pet)
            try container.mainContext.save()
            let intent = ToggleWidgetMealIntent(petID: try #require(pet.intentID), meal: .morning, day: date)
            intent.action = action
            #expect(throws: PetIntentError.failedSave) {
                try action.toggle(id: #require(pet.intentID), meal: .morning, displayedDay: date)
            }
            await #expect(throws: PetIntentError.failedSave) {
                try await intent.perform()
            }
            #expect(store.read()?.pets.first?.completed == 0)
            let saved = ModelContext(container)
            #expect(try saved.fetch(FetchDescriptor<Feed>()).isEmpty)
        }
    }

    @Test("Undo reconciles duplicate records, preserves other meals, and rolls back failed saves")
    func undoMeals() async throws {
        let date = Date.now
        let yesterday = try #require(Calendar.current.date(byAdding: .day, value: -1, to: date))
        try await withAction(at: date) { container, service, store, action in
            let pet = Pet(name: "Luna")
            container.mainContext.insert(pet)
            pet.addFeed(Feed(eveningFed: true, eveningFedStamp: date, feedDate: date,
                             morningFed: true, morningFedStamp: date))
            pet.addFeed(Feed(feedDate: date, morningFed: true, morningFedStamp: date))
            pet.addFeed(Feed(feedDate: yesterday, morningFed: true, morningFedStamp: yesterday))
            try container.mainContext.save()
            let id = try #require(pet.intentID)
            var shouldFail = true
            let failingService = PetCareService(container: container, clock: { date }, save: {
                if shouldFail { throw PetCareError.saveFailed }
                try $0.save()
            })
            let failingPublisher = PetWidgetPublisher(container: container, service: failingService, store: store)
            let intent = ToggleWidgetMealIntent(petID: id, meal: .morning, day: date)
            intent.action = failingPublisher.feedingAction(clock: { date })
            await #expect(throws: PetIntentError.failedSave) {
                try await intent.perform()
            }
            #expect(try service.feedingStatus(id: id).morningTime == date)
            #expect(store.read()?.pets.first?.morningFed == true)
            shouldFail = false
            intent.action = action
            _ = try await intent.perform()
            let status = try service.feedingStatus(id: id)
            #expect(!status.morningFed)
            #expect(status.morningTime == nil)
            #expect(status.eveningFed)
            #expect(status.eveningTime == date)
            #expect(store.read()?.pets.first?.completed == 1)
            let context = ModelContext(container)
            let saved = try #require(context.fetch(FetchDescriptor<Pet>()).first)
            #expect(DailyFeeds.records(for: saved, at: date).allSatisfy { !$0.morningFed && $0.morningFedStamp == nil })
            #expect(DailyFeeds.isFed(.morning, pet: saved, at: yesterday))
        }
    }

    @Test("Widget actions stay in the background and require authentication")
    func policies() {
        #expect(ToggleWidgetMealIntent.supportedModes == .background)
        #expect(ToggleWidgetMealIntent.authenticationPolicy == .requiresAuthentication)
        #expect(!ToggleWidgetMealIntent.isDiscoverable)
    }
}
