import Foundation

enum EventSaveError: LocalizedError {
    case calendarUnavailable

    var errorDescription: String? {
        String(localized: "The calendar is unavailable. Check calendar access and try again.")
    }
}
