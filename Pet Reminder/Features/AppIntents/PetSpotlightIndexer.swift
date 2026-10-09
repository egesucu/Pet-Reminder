import AppIntents
import CoreSpotlight
import Foundation
import OSLog
import Shared

@MainActor
protocol PetSearchIndex {
    var isAvailable: Bool { get }
    func index(_ pets: [PetEntity]) async throws
    func remove(ids: [UUID]) async throws
    func removeAllPets() async throws
}

struct CoreSpotlightPetIndex: PetSearchIndex {

    var isAvailable: Bool { CSSearchableIndex.isIndexingAvailable() }

    func index(_ pets: [PetEntity]) async throws {
        let searchableIndex = CSSearchableIndex(name: "PetReminder.Pets", protectionClass: .complete)
        try await searchableIndex.indexAppEntities(pets)
    }

    func remove(ids: [UUID]) async throws {
        let searchableIndex = CSSearchableIndex(name: "PetReminder.Pets", protectionClass: .complete)
        try await searchableIndex.deleteAppEntities(identifiedBy: ids, ofType: PetEntity.self)
    }

    func removeAllPets() async throws {
        // Restrict cleanup to this entity type, preserving any future indexed app content.
        let searchableIndex = CSSearchableIndex(name: "PetReminder.Pets", protectionClass: .complete)
        try await searchableIndex.deleteAppEntities(ofType: PetEntity.self)
    }
}

/// Serializes index writes and reconciles against saved data, never unfinished UI edits.
@MainActor
final class PetSpotlightIndexer {
    private static let manifestKey = "spotlight.indexedPetIDs"
    private let service: PetCareService
    private let index: any PetSearchIndex
    private let defaults: UserDefaults
    private var indexed: [UUID: Fingerprint] = [:]
    private var tail: Task<Void, any Error>?
    private var latestJob: UUID?
    private var scheduledRefresh: Task<Void, Never>?

    private struct Fingerprint: Equatable {
        let name: String
        let animalType: String
        let breed: String?
        let birthday: Date
        let schedule: String

        init(_ entity: PetEntity) {
            name = entity.name
            animalType = entity.animalType
            breed = entity.breed
            birthday = entity.birthday
            schedule = entity.schedule
        }
    }

    init(service: PetCareService, index: any PetSearchIndex = CoreSpotlightPetIndex(), defaults: UserDefaults = .standard) {
        self.service = service
        self.index = index
        self.defaults = defaults
    }

    func scheduleRefresh() {
        scheduledRefresh?.cancel()
        scheduledRefresh = Task {
            do {
                // Coalesce bursts of save/import notifications before reading the store.
                try await Task.sleep(for: .milliseconds(200))
                try Task.checkCancellation()
                try await refresh()
            } catch is CancellationError {
                return
            } catch {
                Logger.pets.error("Failed to update Spotlight pet index: \(error.localizedDescription)")
            }
        }
    }

    func refresh(force: Bool = false) async throws {
        try await serialize {
            try await self.reconcile(force: force)
        }
    }

    func reindex(ids: [UUID]) async throws {
        try await serialize {
            guard self.index.isAvailable else { return }
            guard let storedIDs = self.persistedIDs else {
                try await self.reconcile(force: true)
                return
            }
            let entities = try self.service.pets(for: ids).map(PetEntity.init)
            let existingIDs = Set(entities.map(\.id))
            let missingIDs = Set(ids).subtracting(existingIDs)
            if !missingIDs.isEmpty { try await self.index.remove(ids: Array(missingIDs)) }
            if !entities.isEmpty { try await self.index.index(entities) }
            self.storeIDs(storedIDs.subtracting(missingIDs).union(existingIDs))
            for id in missingIDs { self.indexed.removeValue(forKey: id) }
            for entity in entities { self.indexed[entity.id] = Fingerprint(entity) }
        }
    }

    private var persistedIDs: Set<UUID>? {
        guard let values = defaults.stringArray(forKey: Self.manifestKey) else { return nil }
        let ids = values.compactMap(UUID.init(uuidString:))
        // A corrupt or cleared manifest requires a full cleanup before rebuilding.
        guard ids.count == values.count else { return nil }
        return Set(ids)
    }

    private func storeIDs(_ ids: Set<UUID>) {
        defaults.set(ids.map(\.uuidString).sorted(), forKey: Self.manifestKey)
    }

    private func reconcile(force: Bool) async throws {
        guard index.isAvailable else { return }
        // Fetch successfully before touching the index: read failures must not erase results.
        let entities = try service.pets().map(PetEntity.init)
        let currentIDs = Set(entities.map(\.id))
        let previousIDs = persistedIDs
        if let previousIDs {
            let removed = previousIDs.subtracting(currentIDs)
            if !removed.isEmpty { try await index.remove(ids: Array(removed)) }
        } else {
            try await index.removeAllPets()
        }
        let changed = entities.filter { force || previousIDs == nil || indexed[$0.id] != Fingerprint($0) }
        if !changed.isEmpty { try await index.index(changed) }
        // Advance state only after every index operation succeeds; failures remain retryable.
        storeIDs(currentIDs)
        indexed = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, Fingerprint($0)) })
    }

    private func serialize(_ operation: @escaping @MainActor () async throws -> Void) async throws {
        let previous = tail
        let token = UUID()
        let job = Task {
            // A failed job must not prevent later refreshes from retrying.
            _ = try? await previous?.value
            try await operation()
        }
        latestJob = token
        tail = job
        defer {
            if latestJob == token {
                tail = nil
                latestJob = nil
            }
        }
        try await job.value
    }
}
