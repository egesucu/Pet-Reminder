import EventKit
import Foundation
import Shared
import Testing
@testable import Pet_Reminder

private final class EventStoreSpy: EventStoreProtocol, @unchecked Sendable {
    private let backingStore: EKEventStore

    var requestAccessResult = true
    var saveShouldFail = false
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
        NSPredicate(value: true)
    }

    func events(matching predicate: NSPredicate) -> [EKEvent] {
        stubEvents
    }

    func saveCalendar(_ calendar: EKCalendar, commit: Bool) throws {
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
@Suite("Event manager")
struct EventManagerTests {

    @Test("First authorization loads calendars and creates the Pet Reminder calendar")
    func firstAuthorizationLoadsCalendars() async throws {
        let store = EventStoreSpy(calendarTitles: ["Personal"])
        let sut = EventManager(
            eventStore: store,
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
        let sut = EventManager(eventStore: store, authorizationStatusProvider: { .fullAccess })
        await sut.reloadEvents()
        await #expect(throws: (any Error).self) {
            try await sut.saveEvent(name: "Vet", start: .now, end: .now, allDay: false)
        }
        #expect(store.savedEvents.isEmpty)
        let empty = EventManager(eventStore: EventStoreSpy(), authorizationStatusProvider: { .fullAccess })
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
            authorizationStatusProvider: { .denied }
        )

        await sut.requestCalendarAccess()

        #expect(sut.status == .denied)
        #expect(sut.calendars.isEmpty)
        #expect(store.savedCalendars.isEmpty)
    }
}
