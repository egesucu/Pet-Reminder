//
//  EventManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
/// A protocol defining the subset of `EKEventStore` interface used by `EventManager`.
import Observation
import EventKit
import OSLog
import Shared
import SharedUI

public protocol EventStoreProtocol: Sendable {
    func calendars(for entityType: EKEntityType) -> [EKCalendar]
    var defaultCalendarForNewEvents: EKCalendar? { get }
    func requestFullAccessToEvents() async throws -> Bool
    func predicateForEvents(withStart startDate: Date, end endDate: Date, calendars: [EKCalendar]?) -> NSPredicate
    func events(matching predicate: NSPredicate) -> [EKEvent]
    func saveCalendar(_ calendar: EKCalendar, commit: Bool) throws
    func save(_ event: EKEvent, span: EKSpan, commit: Bool) throws
    func makeCalendar(for entityType: EKEntityType) -> EKCalendar
    func makeEvent() -> EKEvent
}

extension EKEventStore: @unchecked @retroactive Sendable, EventStoreProtocol {
    public func makeCalendar(for entityType: EKEntityType) -> EKCalendar {
        EKCalendar(for: entityType, eventStore: self)
    }

    public func makeEvent() -> EKEvent {
        EKEvent(eventStore: self)
    }
}

/// Manages calendar events related to pet reminders, including permissions, event creation, and loading.
@MainActor
@Observable
public final class EventManager {

    public typealias AuthorizationStatusProvider = () -> EKAuthorizationStatus

    private let petCalendarTitle = "Pet Reminder"

    // MARK: - Dependencies

    @ObservationIgnored var eventStore: any EventStoreProtocol
    @ObservationIgnored private let authorizationStatusProvider: AuthorizationStatusProvider
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let preferences: UserDefaults
    private static let filterKey = "events.selectedCalendar"
    private static let allCalendarsID = AgendaRules.allCalendarsID
    private var restoringFilter = false

    // MARK: - Properties

    var events: [EKEvent] = [] {
        didSet { updateFilteredEvents() }
    }
    var calendars: [EventCalendar] = []
    var selectedCalendar: EventCalendar? {
        didSet {
            if !restoringFilter {
                preferences.set(selectedCalendar?.id ?? Self.allCalendarsID, forKey: Self.filterKey)
            }
            updateFilteredEvents()
        }
    }
    var petCalendar: EventCalendar?
    var status: Status = .notDetermined
    private(set) var todaysEvents: [EKEvent] = []
    private(set) var futureEvents: [EKEvent] = []

    // MARK: - Demo & Mock Data

    struct Demo {
        static var fakeCalendar: EKCalendar {
            let eventStore = EKEventStore()
            let calendar = EKCalendar(for: .event, eventStore: eventStore)
            calendar.title = "Fake Calendar"
            calendar.cgColor = CGColor(red: 0.52, green: 0.45, blue: 0.334, alpha: 0.545)
            return calendar
        }

        static var exampleEvents: [EKEvent] {
            let eventStore = EKEventStore()
            let fakeCalendar = Demo.fakeCalendar
            var events: [EKEvent] = []
            for index in 0...4 {
                let event = EKEvent(eventStore: eventStore)
                event.title = Strings.demoEvent(index + 1)
                event.startDate = .now
                event.endDate = .now.addingTimeInterval(60)
                event.isAllDay = false
                event.calendar = fakeCalendar
                events.append(event)
            }
            return events
        }
    }

    enum Status: String, Equatable {
        case authorized
        case readOnly
        case denied
        case notDetermined

        static func value(status: EKAuthorizationStatus) -> Self {
            switch status {
            case .notDetermined: return .notDetermined
            case .restricted: return .denied
            case .denied: return .denied
            case .fullAccess: return .authorized
            case .writeOnly: return .readOnly
            case .authorized: return .authorized
            @unknown default: return .denied
            }
        }
    }

    static let demo = EventManager(isDemo: true)

    public init(
        isDemo: Bool = false,
        eventStore: any EventStoreProtocol = EKEventStore(),
        now: @escaping () -> Date = { .now },
        calendar: Calendar = .autoupdatingCurrent,
        preferences: UserDefaults = .standard,
        authorizationStatusProvider: @escaping AuthorizationStatusProvider = {
            EKEventStore.authorizationStatus(for: .event)
        }
    ) {
        self.eventStore = eventStore
        self.authorizationStatusProvider = authorizationStatusProvider
        self.now = now
        self.calendar = calendar
        self.preferences = preferences

        if isDemo {
            events = EventManager.Demo.exampleEvents
            status = .authorized
            restoringFilter = true
            selectedCalendar = nil
            restoringFilter = false
            updateFilteredEvents()
        }
    }

    var fakeCalendar: EKCalendar {
        let calendar = eventStore.makeCalendar(for: .event)
        calendar.title = "Fake Calendar"
        calendar.cgColor = CGColor(red: 0.52, green: 0.45, blue: 0.334, alpha: 0.545)
        return calendar
    }

    private func updateAuthStatus() async {
        status = .value(status: authorizationStatusProvider())
        Logger.events.info("Auth status is: \(self.status.rawValue)")
    }

    public func requestCalendarAccess() async {
        do {
            let result = try await eventStore.requestFullAccessToEvents()
            await updateAuthStatus()
            if result {
                await self.fetchCalendars()
                self.events = await loadEvents()
            } else {
                self.status = .denied
            }
        } catch {
            Logger.events.error("Could not get the auth status: \(error)")
        }
    }

    func formattedEventDateString(for event: EKEvent) -> String {
        if Calendar.current.isDateInToday(event.startDate) {
            return String.formatEventDateTime(current: true, allDay: event.isAllDay, event: event)
        } else {
            return String.formatEventDateTime(current: false, allDay: event.isAllDay, event: event)
        }
    }

    private var rules: AgendaRules { AgendaRules(now: now(), calendar: calendar) }

    private func entry(_ event: EKEvent) -> AgendaEntry {
        AgendaEntry(identifier: event.calendarItemIdentifier,
                    occurrence: event.hasRecurrenceRules ? (event.occurrenceDate ?? event.startDate) : nil,
                    calendarID: event.calendar.calendarIdentifier,
                    title: event.title ?? "", start: event.startDate, end: event.endDate)
    }

    private func updateFilteredEvents() {
        let partition = rules.partition(events.map(entry), selectedID: selectedCalendar?.id)
        todaysEvents = partition.today.map { events[$0] }
        futureEvents = partition.future.map { events[$0] }
    }

    var futureEventDays: [Date] { rules.days(for: futureEvents.map(entry)) }

    func events(on day: Date) -> [EKEvent] {
        futureEvents.filter { calendar.isDate($0.startDate, inSameDayAs: day) }
    }

    func reconciledEvent(_ selected: EKEvent?) -> EKEvent? {
        guard let selected else { return nil }
        return (todaysEvents + futureEvents).first { rules.matches(entry($0), selection: entry(selected)) }
    }

    func fetchCalendars() async {
        guard status == .authorized else { return }
        calendars = eventStore.calendars(for: .event).map { EventCalendar(calendar: $0) }
        await definePetCalendar()
        let saved = preferences.string(forKey: Self.filterKey)
        restoringFilter = true
        let id = rules.selectedCalendarID(saved: saved, available: calendars.map(\.id), petID: petCalendar?.id)
        selectedCalendar = calendars.first { $0.id == id }
        restoringFilter = false
    }

    func definePetCalendar() async {
        petCalendar = await findOrCreatePetCalendar()
    }

    func saveEvent(
        name: String,
        start: Date,
        end: Date,
        allDay: Bool,
        selectedCalendar: EventCalendar? = nil
    ) async throws {
        try await saveEvent(
            eventName: name,
            eventStartDate: start,
            eventEndDate: end,
            isAllDay: allDay,
            selectedCalendar: selectedCalendar ?? petCalendar ?? .init(.empty)
        )
    }

    func findOrCreatePetCalendar() async -> EventCalendar? {
        if let petCalendar = calendars.first(where: { $0.title == petCalendarTitle }) {
            return petCalendar
        } else {
            return await createCalendar()
        }
    }

    private func createCalendar() async -> EventCalendar? {
        let calendar = eventStore.makeCalendar(for: .event)
        calendar.title = petCalendarTitle
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            calendar.source = defaultCalendar.source
        }
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            let petCalendar = EventCalendar(calendar: calendar)
            calendars.append(petCalendar)
            return petCalendar
        } catch {
            Logger.events.error("\(error.localizedDescription)")
            return nil
        }
    }

    func loadEvents() async -> [EKEvent] {
        let window = rules.window
        let predicate = eventStore.predicateForEvents(
            withStart: window.start,
            end: window.end,
            calendars: eventStore.calendars(for: .event)
        )
        return eventStore.events(matching: predicate)
    }

    func saveEvent(
        eventName: String,
        eventStartDate: Date,
        eventEndDate: Date,
        isAllDay: Bool,
        selectedCalendar: EventCalendar
    ) async throws {
        let calendars = eventStore.calendars(for: .event)
        guard let petCalendar = calendars.first(where: { $0.calendarIdentifier == selectedCalendar.id }) else {
            throw EventSaveError.calendarUnavailable
        }

        let newEvent = eventStore.makeEvent()
        newEvent.title = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        newEvent.isAllDay = isAllDay
        // Compute both boundaries before EventKit normalizes all-day date values.
        let dates = eventDates(start: eventStartDate, end: eventEndDate, allDay: isAllDay)
        newEvent.startDate = dates.start
        // EventKit treats the end date of an all-day event as inclusive.
        // Use the last instant before the next midnight to avoid a second day.
        newEvent.endDate = isAllDay ? dates.end.addingTimeInterval(-1) : dates.end
        newEvent.calendar = petCalendar

        // Fire 10 minutes before the event start
        let alarm = EKAlarm(relativeOffset: -600)
        newEvent.addAlarm(alarm)
        newEvent.notes = "Pet Event"

        try eventStore.save(newEvent, span: .thisEvent, commit: true)
    }

    func eventDates(start: Date, end: Date, allDay: Bool) -> (start: Date, end: Date) {
        rules.eventDates(start: start, end: end, allDay: allDay)
    }

    func reloadEvents() async {
        await updateAuthStatus()

        if status == .notDetermined {
            await requestCalendarAccess()
            return
        }

        guard status == .authorized else {
            events = []
            calendars = []
            petCalendar = nil
            return
        }

        await fetchCalendars()
        self.events = await loadEvents()
    }
}
