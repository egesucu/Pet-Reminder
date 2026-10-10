import Foundation
import Observation

@MainActor
@Observable
final class EventCreationState {
    var name = ""
    var allDay = false
    var start: Date
    var end: Date
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    var showError = false

    init(now: Date = .now) {
        start = now.addingTimeInterval(3600)
        end = now.addingTimeInterval(7200)
    }

    var canSave: Bool {
        !isSaving && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (allDay || end >= start)
    }

    static func adjustedEnd(oldStart: Date, newStart: Date, end: Date) -> Date {
        newStart.addingTimeInterval(max(0, end.timeIntervalSince(oldStart)))
    }

    func save(using operation: (String, Date, Date, Bool) async throws -> Void) async -> Bool {
        guard canSave else { return false }
        isSaving = true
        errorMessage = nil
        showError = false
        defer { isSaving = false }
        do {
            try await operation(name.trimmingCharacters(in: .whitespacesAndNewlines), start, end, allDay)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return false
        }
    }
}
