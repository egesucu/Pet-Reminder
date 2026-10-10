import Foundation

/// Value-only input at the EventKit boundary. An occurrence belongs to its series
/// identifier and occurrence date; editing a nonrecurring event keeps its identity.
struct AgendaEntry: Equatable {
    let identifier: String
    let occurrence: Date?
    let calendarID: String
    let title: String
    let start: Date
    let end: Date
}

struct AgendaRules {
    let now: Date
    let calendar: Calendar
    nonisolated static let allCalendarsID = "__all_calendars__"

    var window: DateInterval {
        DateInterval(start: calendar.startOfDay(for: now),
                     end: calendar.date(byAdding: .month, value: 1, to: now) ?? now)
    }

    func selectedCalendarID(saved: String?, available: [String], petID: String?) -> String? {
        if saved == Self.allCalendarsID { return nil }
        if let saved, available.contains(saved) { return saved }
        return petID.flatMap { available.contains($0) ? $0 : nil }
    }

    func partition(_ entries: [AgendaEntry], selectedID: String?) -> (today: [Int], future: [Int]) {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let sorted = entries.indices.filter { selectedID == nil || entries[$0].calendarID == selectedID }.sorted {
            let a = entries[$0], b = entries[$1]
            if a.start != b.start { return a.start < b.start }
            if a.title != b.title { return a.title < b.title }
            return a.identifier < b.identifier
        }
        return (
            sorted.filter { entries[$0].start < tomorrow && (entries[$0].end > today || entries[$0].start >= today) },
            sorted.filter { entries[$0].start >= tomorrow }
        )
    }

    func days(for entries: [AgendaEntry]) -> [Date] {
        Array(Set(entries.map { calendar.startOfDay(for: $0.start) })).sorted()
    }

    func matches(_ candidate: AgendaEntry, selection: AgendaEntry) -> Bool {
        candidate.identifier == selection.identifier && candidate.occurrence == selection.occurrence
    }

    func eventDates(start: Date, end: Date, allDay: Bool) -> (start: Date, end: Date) {
        guard allDay else { return (start, end) }
        let midnight = calendar.startOfDay(for: start)
        return (midnight, calendar.date(byAdding: .day, value: 1, to: midnight)!)
    }
}
