import AppIntents
import Foundation
import WidgetKit

struct WidgetPetEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Pet"
    static let defaultQuery = WidgetPetQuery()
    let id: UUID
    let name: String
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
}

struct WidgetPetQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [WidgetPetEntity] {
        let pets = WidgetSnapshotStore().read()?.pets ?? []
        return identifiers.compactMap { id in
            pets.first { $0.id == id }.map { WidgetPetEntity(id: $0.id, name: $0.name) }
        }
    }

    func suggestedEntities() async throws -> [WidgetPetEntity] {
        (WidgetSnapshotStore().read()?.pets ?? []).map { WidgetPetEntity(id: $0.id, name: $0.name) }
    }
}

struct SelectWidgetPet: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Choose a pet"
    static let description = IntentDescription("Choose the pet whose meals you want to follow.")
    @Parameter(title: "Pet") var pet: WidgetPetEntity?
}

struct CareEntry: TimelineEntry {
    let date: Date
    let pets: [WidgetPet]
    let selectedID: UUID?
    let hasSnapshot: Bool

    var selectedPet: WidgetPet? {
        if let selectedID { return pets.first { $0.id == selectedID } }
        return pets.first
    }

    static func sample(at date: Date = .now) -> Self {
        Self(date: date, pets: [
            WidgetPet(id: UUID(), name: "Luna", photo: nil, kind: "dog", morningScheduled: true,
                      eveningScheduled: true, morningFed: true, eveningFed: false),
            WidgetPet(id: UUID(), name: "Milo", photo: nil, kind: "cat", morningScheduled: true,
                      eveningScheduled: true, morningFed: true, eveningFed: true),
            WidgetPet(id: UUID(), name: "Coco", photo: nil, kind: "bird", morningScheduled: true,
                      eveningScheduled: false, morningFed: false, eveningFed: false)
        ], selectedID: nil, hasSnapshot: true)
    }
}

enum CareTimeline {
    static func entry(at date: Date, selectedID: UUID? = nil, snapshot: WidgetSnapshot?) -> CareEntry {
        CareEntry(date: date, pets: snapshot?.pets(at: date) ?? [], selectedID: selectedID, hasSnapshot: snapshot != nil)
    }

    static func timeline(selectedID: UUID? = nil) -> Timeline<CareEntry> {
        let now = Date.now
        let calendar = Calendar.current
        let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let snapshot = WidgetSnapshotStore().read()
        // The shared file can be unavailable before the first unlock after a restart.
        guard let snapshot else {
            return Timeline(entries: [entry(at: now, selectedID: selectedID, snapshot: nil)],
                            policy: .after(now.addingTimeInterval(5 * 60)))
        }
        // The next-day entry clears yesterday's completion even if iOS delays a reload.
        return Timeline(entries: [entry(at: now, selectedID: selectedID, snapshot: snapshot),
                                  entry(at: midnight, selectedID: selectedID, snapshot: snapshot)],
                        policy: .after(midnight))
    }
}

struct PetFeedingProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CareEntry { .sample() }
    func snapshot(for configuration: SelectWidgetPet, in context: Context) async -> CareEntry {
        if context.isPreview { return .sample() }
        return CareTimeline.entry(at: .now, selectedID: configuration.pet?.id, snapshot: WidgetSnapshotStore().read())
    }
    func timeline(for configuration: SelectWidgetPet, in context: Context) async -> Timeline<CareEntry> {
        CareTimeline.timeline(selectedID: configuration.pet?.id)
    }
}

struct CareOverviewProvider: TimelineProvider {
    func placeholder(in context: Context) -> CareEntry { .sample() }
    func getSnapshot(in context: Context, completion: @escaping (CareEntry) -> Void) {
        completion(context.isPreview ? .sample() : CareTimeline.entry(at: .now, snapshot: WidgetSnapshotStore().read()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<CareEntry>) -> Void) {
        completion(CareTimeline.timeline())
    }
}
