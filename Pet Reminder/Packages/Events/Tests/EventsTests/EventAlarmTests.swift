import EventKit
import Foundation
import Shared
import Testing
@testable import Events

private final class EventStoreSpy: EventStoreProtocol, @unchecked Sendable {
    private let backingStore: EKEventStore

    var queryStart: Date?
    var queryEnd: Date?
    var requestAccessResult = true
    var saveShouldFail = false
    var calendarSaveShouldFail = false
    var stubEvents: [EKEvent] = []
    private(set) var storedCalendars: [EKCalendar]
    private(set) var savedCalendars: [EKCalendar] = []
    private(set) var savedEvents: [EKEvent] = []

    init(calendarTitles: [String] = []) {
        let backingStore = EKEventStore()
        self.backingStore = backingStore
        storedCalendars = calendarTitles.map { title in
            let calendar = EKCalendar(for: .event, eventStore: backingStore)
            calendar.title = title
            return calendar
        }
    }

    func removeLastCalendar() { storedCalendars.removeLast() }

    func calendars(for entityType: EKEntityType) -> [EKCalendar] {
        storedCalendars
    }

    var defaultCalendarForNewEvents: EKCalendar? {
        storedCalendars.first
    }

    func requestFullAccessToEvents() async throws -> Bool {
        requestAccessResult
    }

    func predicateForEvents(
        withStart startDate: Date,
        end endDate: Date,
        calendars: [EKCalendar]?
    ) -> NSPredicate {
        queryStart = startDate
        queryEnd = endDate
        return NSPredicate(value: true)
    }

    func events(matching predicate: NSPredicate) -> [EKEvent] {
        stubEvents
    }

    func saveCalendar(_ calendar: EKCalendar, commit: Bool) throws {
        if calendarSaveShouldFail { throw NSError(domain: "EventStoreTests", code: 2) }
        savedCalendars.append(calendar)
        storedCalendars.append(calendar)
    }

    func save(_ event: EKEvent, span: EKSpan, commit: Bool) throws {
        if saveShouldFail { throw NSError(domain: "EventStoreTests", code: 1) }
        savedEvents.append(event)
    }

    func makeCalendar(for entityType: EKEntityType) -> EKCalendar {
        EKCalendar(for: entityType, eventStore: backingStore)
    }

    func makeEvent() -> EKEvent {
        EKEvent(eventStore: backingStore)
    }
}

@MainActor
@Suite("EventKit adapter contract")
struct EventManagerTests {

    @Test("First authorization loads calendars and creates the Pet Reminder calendar")
    func firstAuthorizationLoadsCalendars() async throws {
        let store = EventStoreSpy(calendarTitles: ["Personal"])
        let sut = EventManager(
            eventStore: store,
            preferences: UserDefaults(suiteName: UUID().uuidString)!,
            authorizationStatusProvider: { .fullAccess }
        )

        await sut.requestCalendarAccess()

        #expect(sut.status == .authorized)
        #expect(sut.calendars.contains { $0.title == "Personal" })
        #expect(sut.calendars.contains { $0.title == "Pet Reminder" })
        #expect(store.savedCalendars.count == 1)
        #expect(store.savedCalendars.first?.title == "Pet Reminder")
    }

    @Test("Saved events retain dates and receive a ten-minute alarm")
    func eventAlarmAndDates() async throws {
        let store = EventStoreSpy(calendarTitles: ["Pet Reminder"])
        let sut = EventManager(
            eventStore: store,
            preferences: UserDefaults(suiteName: UUID().uuidString)!,
            authorizationStatusProvider: { .fullAccess }
        )
        await sut.reloadEvents()

        let start = Date(timeIntervalSince1970: 10_000)
        let end = Date(timeIntervalSince1970: 20_000)
        try await sut.saveEvent(name: "Vet Visit", start: start, end: end, allDay: false)

        let savedEvent = try #require(store.savedEvents.first)
        let alarm = try #require(savedEvent.alarms?.first)
        #expect(savedEvent.title == "Vet Visit")
        #expect(savedEvent.startDate == start)
        #expect(savedEvent.endDate == end)
        #expect(alarm.relativeOffset == -600)
    }

    @Test("Save errors and missing calendars propagate to the caller")
    func saveFailures() async {
        let store = EventStoreSpy(calendarTitles: ["Pet Reminder"])
        store.saveShouldFail = true
        let sut = EventManager(eventStore: store, preferences: UserDefaults(suiteName: UUID().uuidString)!, authorizationStatusProvider: { .fullAccess })
        await sut.reloadEvents()
        await #expect(throws: (any Error).self) {
            try await sut.saveEvent(name: "Vet", start: .now, end: .now, allDay: false)
        }
        #expect(store.savedEvents.isEmpty)
        let empty = EventManager(eventStore: EventStoreSpy(), preferences: UserDefaults(suiteName: UUID().uuidString)!, authorizationStatusProvider: { .fullAccess })
        await #expect(throws: EventSaveError.self) {
            try await empty.saveEvent(name: "Vet", start: .now, end: .now, allDay: false)
        }
    }

    @Test("Denied calendar access does not load calendars")
    func deniedCalendarAccess() async {
        let store = EventStoreSpy(calendarTitles: ["Personal"])
        store.requestAccessResult = false
        let sut = EventManager(
            eventStore: store,
            preferences: UserDefaults(suiteName: UUID().uuidString)!,
            authorizationStatusProvider: { .denied }
        )

        await sut.requestCalendarAccess()

        #expect(sut.status == .denied)
        #expect(sut.calendars.isEmpty)
        #expect(store.savedCalendars.isEmpty)
    }
}

@MainActor
@Suite("EventKit agenda integration")
struct AgendaReliabilityTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }

    private func date(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour))!
    }

    private func event(_ store: EventStoreSpy, start: Date, end: Date, calendarIndex: Int = 0) -> EKEvent {
        let event = store.makeEvent()
        event.calendar = store.storedCalendars[calendarIndex]
        event.title = "Vet visit"
        event.startDate = start
        event.endDate = end
        return event
    }

    @Test("Pet filter defaults, persists by identifier, and recovers after removal")
    func filterPersistence() async {
        let preferences = UserDefaults(suiteName: UUID().uuidString)!
        let store = EventStoreSpy(calendarTitles: ["Pet Reminder", "Personal", "Personal"])
        let sut = EventManager(eventStore: store, preferences: preferences, authorizationStatusProvider: { .fullAccess })
        await sut.reloadEvents()
        #expect(sut.selectedCalendar?.id == store.storedCalendars[0].calendarIdentifier)
        sut.selectedCalendar = sut.calendars[2]
        let restored = EventManager(eventStore: store, preferences: preferences, authorizationStatusProvider: { .fullAccess })
        await restored.reloadEvents()
        #expect(restored.selectedCalendar?.id == store.storedCalendars[2].calendarIdentifier)
        store.removeLastCalendar()
        await restored.reloadEvents()
        #expect(restored.selectedCalendar?.id == restored.petCalendar?.id)
        restored.selectedCalendar = nil
        await sut.reloadEvents()
        #expect(sut.selectedCalendar == nil)
    }

    @Test("Same-name calendars remain distinct; ongoing events and date groups are ordered")
    func groupingAndIdentity() async {
        let store = EventStoreSpy(calendarTitles: ["Pet Reminder", "Personal", "Personal"])
        let today = date(8)
        let ongoing = event(store, start: date(7), end: date(9), calendarIndex: 1)
        let later = event(store, start: date(10), end: date(10, hour: 13), calendarIndex: 1)
        let next = event(store, start: date(9), end: date(9, hour: 13), calendarIndex: 1)
        let unrelated = event(store, start: date(9), end: date(9, hour: 13), calendarIndex: 2)
        store.stubEvents = [later, unrelated, next, ongoing]
        let sut = EventManager(eventStore: store, now: { today }, calendar: calendar,
            preferences: UserDefaults(suiteName: UUID().uuidString)!, authorizationStatusProvider: { .fullAccess })
        await sut.reloadEvents()
        sut.selectedCalendar = sut.calendars[1]
        #expect(sut.todaysEvents == [ongoing])
        #expect(sut.futureEvents == [next, later])
        #expect(sut.futureEventDays.count == 2)
        #expect(sut.events(on: calendar.startOfDay(for: date(9))) == [next])
        #expect(store.queryStart == calendar.startOfDay(for: today))
        #expect(store.queryEnd == calendar.date(byAdding: .month, value: 1, to: today))
        #expect(sut.reconciledEvent(next) === next)
        sut.selectedCalendar = sut.calendars[2]
        #expect(sut.reconciledEvent(next) == nil)
        sut.selectedCalendar = nil
        store.stubEvents = []
        await sut.reloadEvents()
        #expect(sut.reconciledEvent(next) == nil)
    }

    @Test("All-day events span local midnights across daylight saving")
    func allDayBoundaries() async throws {
        let store = EventStoreSpy(calendarTitles: ["Pet Reminder"])
        let sut = EventManager(eventStore: store, calendar: calendar,
            preferences: UserDefaults(suiteName: UUID().uuidString)!, authorizationStatusProvider: { .fullAccess })
        await sut.reloadEvents()
        let dates = sut.eventDates(start: date(8), end: date(10), allDay: true)
        #expect(dates.start == calendar.startOfDay(for: date(8)))
        #expect(dates.end == calendar.startOfDay(for: date(9)))
        #expect(dates.end.timeIntervalSince(dates.start) == 23 * 3600)
        // EventKit all-day dates float in the device timezone. Verify the actual
        // save in that timezone separately from the injected DST calculations.
        let deviceCalendar = Calendar.current
        let deviceSut = EventManager(eventStore: store, calendar: deviceCalendar,
            preferences: UserDefaults(suiteName: UUID().uuidString)!, authorizationStatusProvider: { .fullAccess })
        await deviceSut.reloadEvents()
        try await deviceSut.saveEvent(name: "  Vet  ", start: date(8), end: date(10), allDay: true)
        let saved = try #require(store.savedEvents.first)
        #expect(saved.title == "Vet")
        #expect(saved.startDate == deviceCalendar.startOfDay(for: date(8)))
        let nextMidnight = try #require(deviceCalendar.date(byAdding: .day, value: 1, to: saved.startDate))
        #expect(saved.endDate == nextMidnight.addingTimeInterval(-1))
        #expect(saved.isAllDay)
    }

    @Test("Unavailable Pet Reminder calendar falls back to All Calendars")
    func unavailablePetCalendar() async {
        let store = EventStoreSpy(calendarTitles: ["Personal"])
        store.calendarSaveShouldFail = true
        let preferences = UserDefaults(suiteName: UUID().uuidString)!
        preferences.set("missing-calendar", forKey: "events.selectedCalendar")
        let sut = EventManager(eventStore: store, preferences: preferences, authorizationStatusProvider: { .fullAccess })
        await sut.reloadEvents()
        #expect(sut.petCalendar == nil)
        #expect(sut.selectedCalendar == nil)
    }

    @Test("Write-only access does not attempt to load events")
    func writeOnlyAccess() async {
        let store = EventStoreSpy(calendarTitles: ["Pet Reminder"])
        let sut = EventManager(eventStore: store, preferences: UserDefaults(suiteName: UUID().uuidString)!,
            authorizationStatusProvider: { .writeOnly })
        await sut.reloadEvents()
        #expect(sut.status == .readOnly)
        #expect(store.queryStart == nil)
        #expect(sut.events.isEmpty)
    }

    @Test("Detail dates handle inclusive and exclusive all-day ends without adding a day")
    func detailDateBoundaries() {
        let start = calendar.startOfDay(for: date(8))
        let nextDay = calendar.startOfDay(for: date(9))
        let inclusive = nextDay.addingTimeInterval(-1)
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: nextDay, allDay: true, calendar: calendar) == inclusive)
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: inclusive, allDay: true, calendar: calendar) == inclusive)
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: nextDay, allDay: false, calendar: calendar) == nextDay)
        let multiDayEnd = calendar.startOfDay(for: date(10))
        #expect(EventDetailFormatting.lastDisplayedDay(start: start, end: multiDayEnd, allDay: true, calendar: calendar) == multiDayEnd.addingTimeInterval(-1))
    }

    @Test("Moving a timed start preserves its duration")
    func timedDuration() {
        let end = AddEvent.adjustedEndDate(oldStart: date(8), newStart: date(9), end: date(8, hour: 14))
        #expect(end == date(9, hour: 14))
    }
}
