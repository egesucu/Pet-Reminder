import Foundation
import Shared
import SwiftData
import Testing
@testable import Pet_Reminder

@MainActor
struct DailyFeedsTests {
    @Test("A new day starts unchecked and a tap records that day's feed")
    func midnightRollover() throws {
        let container = try ModelContainer(
            for: Pet.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let pet = Pet(name: "Max")
        context.insert(pet)
        let yesterday = Calendar.current.startOfDay(for: .now)
        let tomorrow = try #require(Calendar.current.date(byAdding: .day, value: 1, to: yesterday))
        try DailyFeeds.toggle(.morning, pet: pet, at: yesterday, context: context)
        #expect(DailyFeeds.isFed(.morning, pet: pet, at: yesterday))
        #expect(!DailyFeeds.isFed(.morning, pet: pet, at: tomorrow))
        try DailyFeeds.toggle(.morning, pet: pet, at: tomorrow, context: context)
        #expect(DailyFeeds.isFed(.morning, pet: pet, at: tomorrow))
        #expect(pet.feeds?.count == 2)
    }

    @Test("Synced changes on the same pet immediately affect reads and the next toggle")
    func syncedRecords() throws {
        let container = try ModelContainer(
            for: Pet.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let pet = Pet(name: "Max")
        context.insert(pet)
        let now = Date.now
        #expect(!DailyFeeds.isFed(.morning, pet: pet, at: now))
        let synced = Feed(feedDate: now, morningFed: true, morningFedStamp: now)
        pet.addFeed(synced)
        pet.addFeed(Feed(feedDate: now, morningFed: true, morningFedStamp: now))
        try context.save()
        #expect(DailyFeeds.isFed(.morning, pet: pet, at: now))
        try DailyFeeds.toggle(.morning, pet: pet, at: now, context: context)
        #expect(!DailyFeeds.isFed(.morning, pet: pet, at: now))
        #expect(pet.feeds?.allSatisfy { $0.morningFedStamp == nil } == true)
        synced.eveningFed = true
        #expect(DailyFeeds.isFed(.evening, pet: pet, at: now))
    }
}
