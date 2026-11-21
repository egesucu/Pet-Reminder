import AppIntents
import Foundation
import OSLog

nonisolated enum WidgetMeal: String, AppEnum {
    case morning, evening

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Meal"
    static let caseDisplayRepresentations: [WidgetMeal: DisplayRepresentation] = [
        .morning: "Morning", .evening: "Evening"
    ]
}

/// Registered by the app, which owns the existing SwiftData store and feeding service.
@MainActor
final class WidgetFeedingAction {
    private let toggleAndPublish: (UUID, WidgetMeal, Bool?) throws -> Void
    private let refresh: () throws -> Void
    private let clock: () -> Date
    private let calendar: () -> Calendar

    init(toggleAndPublish: @escaping (UUID, WidgetMeal, Bool?) throws -> Void,
         refresh: @escaping () throws -> Void,
         clock: @escaping () -> Date = { .now },
         calendar: @escaping () -> Calendar = { .current }) {
        self.toggleAndPublish = toggleAndPublish
        self.refresh = refresh
        self.clock = clock
        self.calendar = calendar
    }

    func toggle(id: UUID, meal: WidgetMeal, displayedDay: Date, expectedFed: Bool? = nil) throws {
        do {
            // An archived toggle from yesterday must not change a different day's meals.
            if calendar().isDate(displayedDay, inSameDayAs: clock()) {
                try toggleAndPublish(id, meal, expectedFed)
            } else {
                try refresh()
            }
        } catch {
            // Reconcile deleted pets, changed schedules, or a rolled-back save as well.
            try? refresh()
            throw error
        }
    }
}

/// The app process handles writes without presenting its UI.
/// The widget extension reads snapshots and never opens the app's private SwiftData store.
struct ToggleWidgetMealIntent: AppIntent {
    nonisolated static let allowedExecutionTargets: ExecutionTargets = .main
    nonisolated static let title: LocalizedStringResource = "Update Meal Status"
    nonisolated static let supportedModes: IntentModes = .background
    nonisolated static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    nonisolated static let isDiscoverable = false

    @Parameter(title: "Pet") var petID: String
    @Parameter(title: "Meal") var meal: WidgetMeal
    @Parameter(title: "Day") var day: Date
    @Parameter(title: "Fed") var expectedFed: Bool?
    @Dependency var action: WidgetFeedingAction

    init() { }

    init(petID: UUID, meal: WidgetMeal, day: Date, expectedFed: Bool? = nil) {
        self.petID = petID.uuidString
        self.meal = meal
        self.day = day
        self.expectedFed = expectedFed
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let clock = ContinuousClock()
        let started = clock.now
        let logger = Logger(subsystem: "com.egesucu.Pet-Reminder", category: "WidgetFeeding")
        defer {
            logger.debug("Widget meal intent finished after \(String(describing: started.duration(to: clock.now)), privacy: .public)")
        }
        guard let id = UUID(uuidString: petID) else { throw WidgetMealError.missingPet }
        try action.toggle(id: id, meal: meal, displayedDay: day, expectedFed: expectedFed)
        return .result()
    }
}

nonisolated enum WidgetMealError: LocalizedError {
    case missingPet

    var errorDescription: String? {
        String(localized: "This pet is no longer available. Choose a pet again.")
    }
}
