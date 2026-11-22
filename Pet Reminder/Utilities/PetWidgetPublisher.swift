import Foundation
import OSLog
import PetCare
import Shared
import SharedUI
import SwiftData
import WidgetKit

@MainActor
final class PetWidgetPublisher {
    private let container: ModelContainer
    private let service: PetCareService
    private let store: WidgetSnapshotStore
    private var refreshTask: Task<Void, Never>?
    private var needsTimelineReload = false

    init(container: ModelContainer, service: PetCareService, store: WidgetSnapshotStore = .init()) {
        self.container = container
        self.service = service
        self.store = store
    }

    func scheduleRefresh(reloadTimelines: Bool = false) {
        needsTimelineReload = needsTimelineReload || reloadTimelines
        refreshTask?.cancel()
        refreshTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(200))
                try Task.checkCancellation()
                try refresh(reloadTimelines: needsTimelineReload)
                needsTimelineReload = false
            } catch is CancellationError {
                return
            } catch {
                Logger.pets.error("Failed to publish widget data: \(error.localizedDescription)")
            }
        }
    }

    func feedingAction(clock: @escaping () -> Date = { .now }) -> WidgetFeedingAction {
        WidgetFeedingAction(toggleAndPublish: { [service] id, meal, expectedFed in
            let status = try intentOperation {
                try service.toggleFed(id: id, meal: meal == .morning ? .morning : .evening, expectedFed: expectedFed)
            }
            try self.publishMealStatus(status, at: clock())
        }, refresh: {
            try self.refresh(at: clock())
        }, clock: clock)
    }

    private func publishMealStatus(_ status: FeedingSnapshot, at date: Date) throws {
        // Reuse exported portraits for the common case so image processing stays off the tap path.
        guard let snapshot = store.read(),
              Calendar.current.isDate(snapshot.date, inSameDayAs: date),
              Calendar.current.isDate(status.day, inSameDayAs: date),
              let index = snapshot.pets.firstIndex(where: { $0.id == status.pet.id }),
              snapshot.pets[index].name == status.pet.name else {
            try refresh(at: date)
            return
        }

        var pets = snapshot.pets
        pets[index] = WidgetPet(
            id: status.pet.id, name: status.pet.name, photo: pets[index].photo,
            kind: status.pet.kind.rawValue,
            morningScheduled: status.pet.schedule != .evening,
            eveningScheduled: status.pet.schedule != .morning,
            morningFed: status.morningFed, eveningFed: status.eveningFed
        )
        try publish(WidgetSnapshot(date: date, pets: pets))
    }

    func refresh(at date: Date = .now, reloadTimelines: Bool = false) throws {
        // Resolve any legacy IDs through the existing care service, then read saved models.
        _ = try service.pets()
        let context = ModelContext(container)
        let pets = try context.fetch(FetchDescriptor<Pet>(sortBy: [SortDescriptor(\Pet.name)]))
        let snapshots = pets.compactMap { pet -> WidgetPet? in
            guard let id = pet.intentID else { return nil }
            return WidgetPet(
                id: id, name: pet.name,
                photo: pet.image.flatMap { ImageDownsampling.downsampleIfNeeded(data: $0, maxDimension: 192) },
                kind: pet.kind.rawValue,
                morningScheduled: pet.feedSelection != .evening,
                eveningScheduled: pet.feedSelection != .morning,
                morningFed: DailyFeeds.isFed(.morning, pet: pet, at: date),
                eveningFed: DailyFeeds.isFed(.evening, pet: pet, at: date)
            )
        }
        try publish(WidgetSnapshot(date: date, pets: snapshots), reloadTimelines: reloadTimelines)
    }

    private func publish(_ snapshot: WidgetSnapshot, reloadTimelines: Bool = false) throws {
        let changed = try store.write(snapshot)
        if changed || reloadTimelines {
            // Send one request for the sibling widgets that also display the changed meal.
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
