import Foundation
import Testing
@testable import Events

@MainActor
@Suite("Deterministic agenda rules")
struct AgendaRulesTests {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(identifier: "America/New_York")!
        return value
    }
    private func date(_ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }
    private func date(_ day: Int, hour: Int = 12) -> Date { date(3, day, hour: hour) }
    private var rules: AgendaRules { AgendaRules(now: date(8), calendar: calendar) }
    private func entry(_ id: String, day: Int, endDay: Int? = nil, calendarID: String = "pet", title: String = "Vet") -> AgendaEntry {
        AgendaEntry(identifier: id, occurrence: nil, calendarID: calendarID, title: title,
                    start: date(day), end: endDay.map { date($0) } ?? date(day, hour: 13))
    }

    @Test("Filter restores identifiers, explicit All, and missing-calendar fallbacks",
          arguments: [nil, "pet", "personal-2", "missing", AgendaRules.allCalendarsID] as [String?])
    func filters(saved: String?) {
        let expected = saved == AgendaRules.allCalendarsID ? nil : (saved == "personal-2" ? "personal-2" : "pet")
        #expect(rules.selectedCalendarID(saved: saved, available: ["pet", "personal-1", "personal-2"], petID: "pet") == expected)
        #expect(rules.selectedCalendarID(saved: "missing", available: ["personal-1"], petID: nil) == nil)
        #expect(rules.selectedCalendarID(saved: nil, available: [], petID: "removed-pet") == nil)
    }

    @Test("Identifier filtering distinguishes calendars with identical display names")
    func identifiers() {
        let input = [entry("one", day: 9, calendarID: "personal-1"), entry("two", day: 9, calendarID: "personal-2")]
        #expect(rules.partition(input, selectedID: "personal-2").future == [1])
        #expect(rules.partition(input, selectedID: nil).future == [0, 1])
    }

    @Test("Chronological sections include ongoing events and exclude completed prior days")
    func grouping() {
        let input = [entry("later", day: 10), entry("ongoing", day: 7, endDay: 9),
                     entry("next", day: 9), entry("expired", day: 6), entry("today", day: 8)]
        let output = rules.partition(input, selectedID: nil)
        #expect(output.today == [1, 4])
        #expect(output.future == [2, 0])
        #expect(rules.days(for: output.future.map { input[$0] }) == [calendar.startOfDay(for: date(9)), calendar.startOfDay(for: date(10))])
    }

    @Test("Midnight boundaries do not put tomorrow or an ended ongoing event in Today")
    func midnight() {
        let today = calendar.startOfDay(for: date(8)), tomorrow = calendar.startOfDay(for: date(9))
        let input = [AgendaEntry(identifier: "ended", occurrence: nil, calendarID: "pet", title: "", start: date(7), end: today),
                     AgendaEntry(identifier: "tomorrow", occurrence: nil, calendarID: "pet", title: "", start: tomorrow, end: tomorrow),
                     AgendaEntry(identifier: "instant", occurrence: nil, calendarID: "pet", title: "", start: today, end: today)]
        #expect(rules.partition(input, selectedID: nil).today == [2])
        #expect(rules.partition(input, selectedID: nil).future == [1])
    }

    @Test("Equal starts sort by title, then identifier")
    func ties() {
        let input = [entry("z", day: 9, title: "B"), entry("b", day: 9, title: "A"), entry("a", day: 9, title: "A")]
        #expect(rules.partition(input, selectedID: nil).future == [2, 1, 0])
    }

    @Test("Window starts today and advances a calendar month, including month-end clamping",
          arguments: [(3, 8, 4, 8), (1, 31, 2, 28), (12, 10, 1, 10)])
    func queryWindow(_ value: (Int, Int, Int, Int)) {
        let now = date(value.0, value.1)
        let window = AgendaRules(now: now, calendar: calendar).window
        #expect(window.start == calendar.startOfDay(for: now))
        let end = calendar.dateComponents([.year, .month, .day, .hour], from: window.end)
        #expect(end.month == value.2 && end.day == value.3 && end.hour == 12)
        #expect(end.year == (value.0 == 12 ? 2027 : 2026))
    }

    @Test("All-day saves use local midnights on 23-, 24-, and 25-hour days",
          arguments: [(3, 8, 23), (3, 9, 24), (11, 1, 25)])
    func daylightSaving(_ value: (Int, Int, Int)) {
        let start = date(value.0, value.1)
        let dates = rules.eventDates(start: start, end: start.addingTimeInterval(200_000), allDay: true)
        #expect(dates.start == calendar.startOfDay(for: start))
        #expect(dates.end == calendar.date(byAdding: .day, value: 1, to: dates.start))
        #expect(dates.end.timeIntervalSince(dates.start) == Double(value.2 * 3600))
        let timed = rules.eventDates(start: start, end: start.addingTimeInterval(7200), allDay: false)
        #expect(timed.start == start && timed.end == start.addingTimeInterval(7200))
    }

    @Test("Recurring selection distinguishes occurrences and retains identity after editing")
    func selections() {
        let selected = entry("single", day: 9)
        #expect(rules.matches(entry("single", day: 10), selection: selected))
        #expect(!rules.matches(entry("different", day: 9), selection: selected))
        let first = AgendaEntry(identifier: "series", occurrence: date(9), calendarID: "pet", title: "A", start: date(9), end: date(9))
        let second = AgendaEntry(identifier: "series", occurrence: date(10), calendarID: "pet", title: "A", start: date(10), end: date(10))
        #expect(!rules.matches(second, selection: first))
        #expect([second].first { rules.matches($0, selection: first) } == nil)
        #expect([AgendaEntry]().first { rules.matches($0, selection: selected) } == nil)
    }

    @Test("Inclusive and exclusive all-day detail ends show the same final day")
    func detailDates() {
        let start = calendar.startOfDay(for: date(8)), end = calendar.startOfDay(for: date(9))
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: end, allDay: true, calendar: calendar) == end.addingTimeInterval(-1))
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: end.addingTimeInterval(-1), allDay: true, calendar: calendar) == end.addingTimeInterval(-1))
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: end, allDay: false, calendar: calendar) == end)
    }
}

@MainActor
@Suite("Event creation state")
struct EventCreationStateTests {
    private let now = Date(timeIntervalSince1970: 1_000_000)

    @Test("Blank names and reversed timed dates cannot save")
    func validation() async {
        let state = EventCreationState(now: now)
        for name in ["", " ", "\n\t"] {
            state.name = name
            #expect(!state.canSave)
        }
        var calls = 0
        #expect(await state.save { _, _, _, _ in calls += 1 } == false)
        #expect(calls == 0)
        state.name = "Vet"
        state.end = state.start.addingTimeInterval(-1)
        #expect(!state.canSave)
        state.allDay = true
        #expect(state.canSave)
        state.allDay = false
        state.end = state.start
        #expect(state.canSave)
    }

    @Test("Failure preserves the complete draft and a successful retry clears the error")
    func retry() async {
        struct Failure: LocalizedError { var errorDescription: String? { "Fixture failure" } }
        let state = EventCreationState(now: now)
        state.name = "  Vet visit  "
        state.allDay = true
        let start = state.start, end = state.end
        #expect(await state.save { _, _, _, _ in throw Failure() } == false)
        #expect(state.name == "  Vet visit  " && state.start == start && state.end == end && state.allDay)
        #expect(state.showError && state.errorMessage == "Fixture failure" && !state.isSaving && state.canSave)
        let success = await state.save { name, savedStart, savedEnd, allDay in
            #expect(name == "Vet visit" && savedStart == start && savedEnd == end && allDay)
        }
        #expect(success && !state.showError && state.errorMessage == nil && !state.isSaving)
    }

    @Test("Saving feedback prevents duplicate submissions until completion")
    func duplicateSaves() async {
        let state = EventCreationState(now: now)
        state.name = "Vet"
        var completion: CheckedContinuation<Void, Never>?
        let first = Task { await state.save { _, _, _, _ in
            await withCheckedContinuation { completion = $0 }
        } }
        while completion == nil { await Task.yield() }
        #expect(state.isSaving && !state.canSave)
        var duplicateCalls = 0
        #expect(await state.save { _, _, _, _ in duplicateCalls += 1 } == false)
        #expect(duplicateCalls == 0)
        completion?.resume()
        #expect(await first.value)
        #expect(!state.isSaving && state.canSave)
    }

    @Test("Moving the start preserves duration and clamps invalid negative duration",
          arguments: [0.0, 3600.0, 7200.0, -60.0])
    func duration(_ seconds: Double) {
        let moved = now.addingTimeInterval(86_400)
        #expect(EventCreationState.adjustedEnd(oldStart: now, newStart: moved, end: now.addingTimeInterval(seconds)) == moved.addingTimeInterval(max(0, seconds)))
    }
}
