import Foundation
import SwiftData
import Observation

public enum PetCareError: Error, Equatable, Sendable {
    case petNotFound
    case dataUnavailable
    case unsupportedMeal
    case saveFailed
}

public struct PetSnapshot: Sendable {
    public let id: UUID
    public let name: String
    public let kind: Kind
    public let breed: String?
    public let birthday: Date
    public let schedule: FeedSelection
}

public struct FeedingSnapshot: Sendable {
    public let pet: PetSnapshot
    public let day: Date
    public let morningFed: Bool
    public let eveningFed: Bool
    public let morningTime: Date?
    public let eveningTime: Date?
}

/// Every operation uses a fresh context so queries see synced changes and never commit UI edits.
@MainActor
@Observable
public final class PetCareService {
    public private(set) var revision: UInt = 0
    @ObservationIgnored
    private let container: ModelContainer
    @ObservationIgnored
    private let clock: () -> Date
    @ObservationIgnored
    private let calendar: () -> Calendar
    @ObservationIgnored
    private let save: (ModelContext) throws -> Void

    public init(
        container: ModelContainer,
        clock: @escaping () -> Date = { .now },
        calendar: @escaping () -> Calendar = { .current },
        save: @escaping (ModelContext) throws -> Void = { try $0.save() }
    ) {
        self.container = container
        self.clock = clock
        self.calendar = calendar
        self.save = save
    }

    public func pets(matching name: String? = nil) throws -> [PetSnapshot] {
        let (_, pets) = try loadPets()
        let term = name.map(Pet.normalizedName) ?? ""
        return try pets.filter { term.isEmpty || Pet.normalizedName(for: $0.name).contains(term) }
            .map(snapshot)
    }

    public func pets(for ids: [UUID]) throws -> [PetSnapshot] {
        let available = try pets()
        return ids.compactMap { id in available.first { $0.id == id } }
    }

    public func pet(id: UUID) throws -> PetSnapshot {
        guard let pet = try pets(for: [id]).first else { throw PetCareError.petNotFound }
        return pet
    }

    public func feedingStatus(id: UUID) throws -> FeedingSnapshot {
        let (_, pets) = try loadPets()
        guard let pet = pets.first(where: { $0.intentID == id }) else { throw PetCareError.petNotFound }
        return try feedingSnapshot(pet, at: clock(), calendar: calendar())
    }

    public func markFed(id: UUID, meal: FeedSelection) throws -> FeedingSnapshot {
        let (context, pets) = try loadPets()
        guard let pet = pets.first(where: { $0.intentID == id }) else { throw PetCareError.petNotFound }
        let now = clock()
        let calendar = calendar()
        try DailyFeeds.markFed(meal, pet: pet, at: now, calendar: calendar, context: context, save: save)
        revision &+= 1
        return try feedingSnapshot(pet, at: now, calendar: calendar)
    }

    private func loadPets() throws -> (ModelContext, [Pet]) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let pets: [Pet]
        do {
            pets = try context.fetch(FetchDescriptor<Pet>(sortBy: [.init(\Pet.name)]))
        } catch {
            throw PetCareError.dataUnavailable
        }
        // Older records may be imported from CloudKit after the local migration has finished.
        for pet in pets where pet.intentID == nil {
            pet.intentID = UUID()
        }
        if context.hasChanges {
            do {
                try save(context)
            } catch {
                context.rollback()
                throw PetCareError.saveFailed
            }
        }
        return (context, pets)
    }

    private func snapshot(_ pet: Pet) throws -> PetSnapshot {
        guard let id = pet.intentID else { throw PetCareError.dataUnavailable }
        return PetSnapshot(id: id, name: pet.name, kind: pet.kind, breed: pet.breed,
                           birthday: pet.birthday, schedule: pet.feedSelection)
    }

    private func feedingSnapshot(_ pet: Pet, at date: Date, calendar: Calendar) throws -> FeedingSnapshot {
        let feeds = DailyFeeds.records(for: pet, at: date, calendar: calendar)
        return FeedingSnapshot(
            pet: try snapshot(pet), day: calendar.startOfDay(for: date),
            morningFed: feeds.contains { $0.morningFed }, eveningFed: feeds.contains { $0.eveningFed },
            morningTime: feeds.filter { $0.morningFed }.compactMap(\.morningFedStamp).max(),
            eveningTime: feeds.filter { $0.eveningFed }.compactMap(\.eveningFedStamp).max()
        )
    }
}
