import EventKit
import Foundation
import Shared

/// Shared summary formatting; native editing retains the full recurrence controls.
enum EventDetailFormatting {
    static func dateDescription(_ event: EKEvent, calendar: Calendar = .current) -> String {
        let end = lastDisplayedDay(start: event.startDate, end: event.endDate, allDay: event.isAllDay, calendar: calendar)
        let startText = event.startDate.formatted(date: .complete, time: .omitted)
        guard !calendar.isDate(event.startDate, inSameDayAs: end) else { return startText }
        return "\(startText) – \(end.formatted(date: .complete, time: .omitted))"
    }

    static func lastDisplayedDay(start: Date, end: Date, allDay: Bool, calendar: Calendar = .current) -> Date {
        // Some sources expose an exclusive midnight; EventKit also exposes inclusive ends.
        if allDay, end > start, end == calendar.startOfDay(for: end) {
            return end.addingTimeInterval(-1)
        }
        return end
    }

    static func timeDescription(_ event: EKEvent) -> String {
        guard !event.isAllDay else { return String(localized: SharedStrings.allDayTitle) }
        return "\(event.startDate.formatted(date: .omitted, time: .shortened)) – \(event.endDate.formatted(date: .omitted, time: .shortened))"
    }

    static func recurrenceDescription(_ rule: EKRecurrenceRule) -> String {
        let interval = Int64(rule.interval)
        switch rule.frequency {
        case .daily:
            return interval == 1 ? String(localized: SharedStrings.resource("Daily"))
                : String(localized: SharedStrings.resource("Every \(interval) days"))
        case .weekly:
            return interval == 1 ? String(localized: SharedStrings.resource("Weekly"))
                : String(localized: SharedStrings.resource("Every \(interval) weeks"))
        case .monthly:
            return interval == 1 ? String(localized: SharedStrings.resource("Monthly"))
                : String(localized: SharedStrings.resource("Every \(interval) months"))
        case .yearly:
            return interval == 1 ? String(localized: SharedStrings.resource("Yearly"))
                : String(localized: SharedStrings.resource("Every \(interval) years"))
        @unknown default:
            return String(localized: SharedStrings.resource("Repeating event"))
        }
    }

    static func alarmDescription(_ alarm: EKAlarm) -> String {
        if alarm.structuredLocation != nil {
            return String(localized: SharedStrings.resource("Location-based reminder"))
        }
        if let date = alarm.absoluteDate { return date.formatted(date: .abbreviated, time: .shortened) }
        if alarm.relativeOffset == 0 { return String(localized: SharedStrings.resource("At time of event")) }
        let duration = Duration.seconds(abs(alarm.relativeOffset))
            .formatted(.units(allowed: [.days, .hours, .minutes, .seconds], width: .wide))
        return alarm.relativeOffset < 0
            ? String(localized: SharedStrings.resource("\(duration) before"))
            : String(localized: SharedStrings.resource("\(duration) after"))
    }
}
