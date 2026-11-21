import Foundation

/// A read-only projection. The app's SwiftData / CloudKit store stays in its original location.
nonisolated struct WidgetPet: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let photo: Data?
    /// Optional so snapshots exported before species support still decode.
    let kind: String?
    let morningScheduled: Bool
    let eveningScheduled: Bool
    let morningFed: Bool
    let eveningFed: Bool

    init(id: UUID, name: String, photo: Data?, kind: String? = nil,
         morningScheduled: Bool, eveningScheduled: Bool, morningFed: Bool, eveningFed: Bool) {
        self.id = id
        self.name = name
        self.photo = photo
        self.kind = kind
        self.morningScheduled = morningScheduled
        self.eveningScheduled = eveningScheduled
        self.morningFed = morningFed
        self.eveningFed = eveningFed
    }

    var symbolName: String {
        switch kind {
        case "dog": "dog.fill"
        case "cat": "cat.fill"
        case "fish": "fish.fill"
        case "bird": "bird.fill"
        default: "heart.fill"
        }
    }

    var scheduled: Int { (morningScheduled ? 1 : 0) + (eveningScheduled ? 1 : 0) }
    var completed: Int { (morningScheduled && morningFed ? 1 : 0) + (eveningScheduled && eveningFed ? 1 : 0) }
    var url: URL { URL(string: "petreminder://pet/\(id.uuidString)")! }

    func resettingMeals() -> Self {
        Self(id: id, name: name, photo: photo, kind: kind, morningScheduled: morningScheduled,
             eveningScheduled: eveningScheduled, morningFed: false, eveningFed: false)
    }
}

nonisolated struct WidgetSnapshot: Codable, Equatable, Sendable {
    static let version = 1
    let version: Int
    let date: Date
    let pets: [WidgetPet]

    init(date: Date, pets: [WidgetPet]) {
        self.version = Self.version
        self.date = date
        self.pets = pets
    }

    func pets(at date: Date, calendar: Calendar = .current) -> [WidgetPet] {
        calendar.isDate(self.date, inSameDayAs: date) ? pets : pets.map { $0.resettingMeals() }
    }
}

nonisolated struct WidgetSnapshotStore: Sendable {
    static let appGroup = "group.com.egesucu.Pet-Reminder"
    static let feedingKind = "PetFeedingWidget"
    static let overviewKind = "PetCareOverviewWidget"
    let directory: URL?

    init(directory: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroup)) {
        self.directory = directory
    }

    private var file: URL? { directory?.appending(path: "widget-snapshot-v1.json") }

    func read() -> WidgetSnapshot? {
        guard let file, let data = try? Data(contentsOf: file),
              let value = try? JSONDecoder().decode(WidgetSnapshot.self, from: data),
              value.version == WidgetSnapshot.version else { return nil }
        return value
    }

    /// Compare the rendered day and pets, avoiding reloads for timestamp-only changes.
    @discardableResult
    func write(_ snapshot: WidgetSnapshot, calendar: Calendar = .current) throws -> Bool {
        guard let file else { throw CocoaError(.fileNoSuchFile) }
        if let previous = read(), calendar.isDate(previous.date, inSameDayAs: snapshot.date),
           previous.pets == snapshot.pets { return false }
        try JSONEncoder().encode(snapshot).write(to: file, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        return true
    }
}
