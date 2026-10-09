import AppIntents
import Foundation
import Shared
import CoreSpotlight

struct PetEntity: IndexedEntity {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Pet"
    nonisolated static let defaultQuery = PetEntityQuery()

    let id: UUID
    @Property(title: "Name", indexingKey: \.title) var name: String
    @Property(title: "Animal Type") var animalType: String
    @Property(title: "Breed") var breed: String?
    @Property(title: "Birthday") var birthday: Date
    @Property(title: "Feeding Schedule") var schedule: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(animalType)", image: .init(systemName: "pawprint"))
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = defaultAttributeSet
        attributes.contentDescription = [animalType, breed].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
        attributes.keywords = ["Pet Reminder", name, animalType, breed].compactMap { $0 }.filter { !$0.isEmpty }
        return attributes
    }

    @MainActor
    init(_ pet: PetSnapshot) {
        id = pet.id
        name = pet.name
        animalType = pet.kind.localizedName
        breed = pet.breed
        birthday = pet.birthday
        schedule = String(localized: pet.schedule.localized)
    }
}

struct PetEntityQuery: EntityStringQuery, IndexedEntityQuery {
    @Dependency var service: PetCareService
    @Dependency var spotlight: PetSpotlightIndexer

    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [PetEntity] {
        try intentOperation { try service.pets(for: identifiers).map(PetEntity.init) }
    }

    @MainActor
    func entities(matching string: String) async throws -> [PetEntity] {
        try intentOperation { try service.pets(matching: string).map(PetEntity.init) }
    }

    @MainActor
    func suggestedEntities() async throws -> [PetEntity] {
        try intentOperation { try service.pets().map(PetEntity.init) }
    }

    nonisolated func reindexEntities(for identifiers: [UUID], indexDescription: CSSearchableIndexDescription) async throws {
        let indexer = await MainActor.run { spotlight }
        try await indexer.reindex(ids: identifiers)
    }

    nonisolated func reindexAllEntities(indexDescription: CSSearchableIndexDescription) async throws {
        let indexer = await MainActor.run { spotlight }
        try await indexer.refresh(force: true)
    }
}

struct PetFeedingStatusEntity: AppEntity {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Feeding Status"
    nonisolated static let defaultQuery = PetFeedingStatusQuery()

    // This entity represents this pet's current-day status, resolved afresh whenever requested.
    let id: UUID
    @Property(title: "Pet") var pet: PetEntity
    @Property(title: "Day") var day: Date
    @Property(title: "Feeding Schedule") var schedule: String
    @Property(title: "Morning Fed") var morningFed: Bool
    @Property(title: "Evening Fed") var eveningFed: Bool
    @Property(title: "Morning Feeding Time") var morningTime: Date?
    @Property(title: "Evening Feeding Time") var eveningTime: Date?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(pet.name)", subtitle: "Today's Feeding Status")
    }

    @MainActor
    init(_ status: FeedingSnapshot) {
        id = status.pet.id
        pet = PetEntity(status.pet)
        day = status.day
        schedule = String(localized: status.pet.schedule.localized)
        morningFed = status.morningFed
        eveningFed = status.eveningFed
        morningTime = status.morningTime
        eveningTime = status.eveningTime
    }

    var dialog: IntentDialog {
        let morning = String(localized: morningFed ? "Fed" : "Not fed")
        let evening = String(localized: eveningFed ? "Fed" : "Not fed")
        return "\(pet.name): Morning — \(morning). Evening — \(evening). Schedule — \(schedule)."
    }
}

struct PetFeedingStatusQuery: EntityQuery {
    @Dependency var service: PetCareService

    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [PetFeedingStatusEntity] {
        try intentOperation {
            try service.pets(for: identifiers).map {
                PetFeedingStatusEntity(try service.feedingStatus(id: $0.id))
            }
        }
    }
}
