import Foundation
import PetCare
import Pets
import Shared
import SwiftData
import Testing
@testable import Pet_Reminder

@MainActor
struct PetWidgetTests {
    private func withStore(_ operation: (WidgetSnapshotStore) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try operation(WidgetSnapshotStore(directory: directory))
    }

    @Test("Snapshots round-trip, coalesce identical refreshes, and clear deleted pets")
    func persistence() throws {
        try withStore { store in
            #expect(store.read() == nil)
            let pet = WidgetPet(id: UUID(), name: "Luna", photo: nil, morningScheduled: true,
                                eveningScheduled: false, morningFed: true, eveningFed: true)
            let snapshot = WidgetSnapshot(date: .now, pets: [pet])
            let firstWrite = try store.write(snapshot)
            #expect(firstWrite)
            #expect(store.read() == snapshot)
            let repeatedWrite = try store.write(snapshot)
            #expect(!repeatedWrite)
            #expect(pet.completed == 1)
            #expect(pet.scheduled == 1)
            let deletionWrite = try store.write(WidgetSnapshot(date: snapshot.date, pets: []))
            #expect(deletionWrite)
            #expect(store.read()?.pets.isEmpty == true)
        }
    }

    @Test("Midnight rollover clears completed meals across a daylight-saving boundary")
    func rollover() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 1)))
        let pet = WidgetPet(id: UUID(), name: "Luna", photo: nil, kind: "dog", morningScheduled: true,
                            eveningScheduled: true, morningFed: true, eveningFed: true)
        let snapshot = WidgetSnapshot(date: date, pets: [pet])
        #expect(snapshot.pets(at: date, calendar: calendar).first?.completed == 2)
        let nextDay = try #require(calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)))
        #expect(snapshot.pets(at: nextDay, calendar: calendar).first?.completed == 0)
        #expect(snapshot.pets(at: nextDay, calendar: calendar).first?.id == pet.id)
        #expect(snapshot.pets(at: nextDay, calendar: calendar).first?.kind == "dog")
    }

    @Test("Snapshots from before species support remain readable")
    func legacySnapshot() throws {
        let id = UUID()
        let data = Data("""
        {"version":1,"date":0,"pets":[{"id":"\(id.uuidString)","name":"Luna",
        "morningScheduled":true,"eveningScheduled":true,"morningFed":true,"eveningFed":false}]}
        """.utf8)
        let snapshot = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        #expect(snapshot.pets.first?.id == id)
        #expect(snapshot.pets.first?.kind == nil)
        #expect(snapshot.pets.first?.completed == 1)
    }

    @Test("A corrupt or unsupported snapshot is unavailable rather than fabricated data")
    func invalidData() throws {
        try withStore { store in
            let file = try #require(store.directory).appending(path: "widget-snapshot-v1.json")
            try Data("broken".utf8).write(to: file)
            #expect(store.read() == nil)
            try Data(#"{"version":99,"date":0,"pets":[]}"#.utf8).write(to: file)
            #expect(store.read() == nil)
        }
    }

    @Test("Publishing reads saved meals and never commits unfinished edits")
    func savedProjection() throws {
        let container = try ModelContainer(for: Pet.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        let pet = Pet(name: "Luna", feedSelection: .evening, kind: .fish)
        let date = Date.now
        pet.addFeed(Feed(eveningFed: true, feedDate: date))
        container.mainContext.insert(pet)
        try container.mainContext.save()
        pet.name = "Unsaved name"
        try withStore { store in
            let publisher = PetWidgetPublisher(container: container, service: PetCareService(container: container), store: store)
            try publisher.refresh(at: date)
            let saved = try #require(store.read()?.pets.first)
            #expect(saved.name == "Luna")
            #expect(saved.kind == "fish")
            #expect(!saved.morningScheduled)
            #expect(saved.eveningScheduled)
            #expect(saved.completed == 1)
            #expect(pet.name == "Unsaved name")
            container.mainContext.rollback()
            container.mainContext.delete(pet)
            try container.mainContext.save()
            try publisher.refresh(at: date)
            #expect(store.read()?.pets.isEmpty == true)
        }
    }

    @Test("Widget URLs use stable identities and malformed identities are ignored")
    func navigation() throws {
        let id = UUID()
        let navigation = AppNavigationCoordinator()
        navigation.handle(try #require(URL(string: "petreminder://pet/\(id.uuidString)")))
        #expect(navigation.pendingRequest?.petID == id)
        let request = navigation.pendingRequest
        navigation.handle(try #require(URL(string: "petreminder://pet/not-an-id")))
        #expect(navigation.pendingRequest == request)
        navigation.handle(try #require(URL(string: "petreminder://pet/\(id.uuidString)/extra")))
        #expect(navigation.pendingRequest == request)
    }
}
