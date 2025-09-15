//
//  EventManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
import Observation
import EventKit
import OSLog
import Shared

/// A protocol defining the subset of `EKEventStore` interface used by `EventManager`.
protocol EventStoreProtocol: Sendable {
    func calendars(for entityType: EKEntityType) -> [EKCalendar]
    var defaultCalendarForNewEvents: EKCalendar? { get }
    func requestFullAccessToEvents() async throws -> Bool
    func predicateForEvents(withStart startDate: Date, end endDate: Date, calendars: [EKCalendar]?) -> NSPredicate
    func events(matching predicate: NSPredicate) -> [EKEvent]
    func saveCalendar(_ calendar: EKCalendar, commit: Bool) throws
    func save(_ event: EKEvent, span: EKSpan, commit: Bool) throws
}

extension EKEventStore: @unchecked @retroactive Sendable, EventStoreProtocol {}

/// Manages calendar events related to pet reminders, including permissions, event creation, and loading.
@MainActor
@Observable
class EventManager {

    private let petCalendarTitle = "Pet Reminder"

    // MARK: - Dependencies

    @ObservationIgnored var eventStore: any EventStoreProtocol

    // MARK: - Properties

    var events: [EKEvent] = []
    var calendars: [EventCalendar] = []
    var selectedCalendar: EventCalendar?
    var petCalendar: EventCalendar?
    var status: Status = .notDetermined

    // MARK: - Demo & Mock Data

    /// Contains static demo data and fallback calendar generation for demo/testing purposes.
    struct Demo {
        /// A fallback/fake calendar used for demo purposes.
        static var fakeCalendar: EKCalendar {
            // Attempt to cast eventStore to EKEventStore for calendar creation.
            // Since this is static and we don't have eventStore instance here,
            // we create a new EKEventStore instance for demo.
            let eventStore = EKEventStore()
            let calendar = EKCalendar(for: .event, eventStore: eventStore)
            calendar.title = "Fake Calendar"
            calendar.cgColor = CGColor(red: 0.52, green: 0.45, blue: 0.334, alpha: 0.545)
            return calendar
        }

        /// Generates example demo events for UI/testing with a fake calendar.
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

    // MARK: - Status Handling

    enum Status: String {
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

    // MARK: - Shared Instances

    static let shared = EventManager()
    static let demo = EventManager(isDemo: true)

    // MARK: - Initialization

    /// Initializes the EventManager with an optional custom event store.
    /// - Parameters:
    ///   - isDemo: Indicates if demo data should be used.
    ///   - eventStore: The event store conforming to `EventStoreProtocol`. Defaults to `EKEventStore`.
    init(isDemo: Bool = false, eventStore: any EventStoreProtocol = EKEventStore()) {
        self.eventStore = eventStore

        if isDemo {
            events = EventManager.Demo.exampleEvents
            status = .authorized
            selectedCalendar = nil
        } else {
            Task { [weak self] in
                guard let self else { return }
                await self.requestCalendarAccess()
            }
        }
    }

    // MARK: - Computed Properties

    /// Returns a calendar instance used for demo or fallback purposes.
    var fakeCalendar: EKCalendar {
        guard let eventStore = self.eventStore as? EKEventStore else {
            Logger.events.error("fakeCalendar: eventStore is not EKEventStore, returning stub calendar.")
            let stubCalendar = EKCalendar(for: .event, eventStore: EKEventStore())
            stubCalendar.title = "Stub Calendar"
            return stubCalendar
        }
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "Fake Calendar"
        calendar.cgColor = CGColor(red: 0.52, green: 0.45, blue: 0.334, alpha: 0.545)
        return calendar
    }

    // MARK: - Authorization

    private func updateAuthStatus() async {
        status = .value(status: EKEventStore.authorizationStatus(for: .event))
        Logger.events.info("Auth status is: \(self.status.rawValue)")
    }

    // MARK: - Calendar Access

    /// Requests access to the user's calendar for event usage.
    func requestCalendarAccess() async {
        do {
            let result = try await eventStore.requestFullAccessToEvents()
            if result {
                await self.fetchCalendars()
            } else {
                self.status = .denied
            }
            await updateAuthStatus()
        } catch {
            Logger.events.error("Could not get the auth status: \(error)")
        }
    }

    // MARK: - Event Formatting

    /// Returns a formatted string representation of an event's date and time.
    /// - Parameter event: The event to format.
    /// - Returns: A formatted date string.
    func formattedEventDateString(for event: EKEvent) -> String {
        if Calendar.current.isDateInToday(event.startDate) {
            return String.formatEventDateTime(current: true, allDay: event.isAllDay, event: event)
        } else {
            return String.formatEventDateTime(current: false, allDay: event.isAllDay, event: event)
        }
    }

    // MARK: - Calendar Fetching & Management

    /// Fetches available calendars and defines the Pet Reminder calendar if authorized.
    func fetchCalendars() async {
        if status == .authorized {
            self.calendars = eventStore.calendars(for: .event).map(\.title).map(EventCalendar.init)
            await definePetCalendar()
        }
    }

    func definePetCalendar() async {
        petCalendar = await findOrCreatePetCalendar()
    }

    // MARK: - Event Creation & Saving

    /// Saves an event using the provided details, targeting the Pet Reminder calendar by default.
    /// - Parameters:
    ///   - name: The title of the event.
    ///   - start: The start date of the event.
    ///   - end: The end date of the event.
    ///   - allDay: Whether the event is all day.
    ///   - selectedCalendar: The calendar to save the event in. Defaults to `petCalendar` or an empty calendar if nil.
    func saveEvent(
        name: String,
        start: Date,
        end: Date,
        allDay: Bool,
        selectedCalendar: EventCalendar? = nil
    ) async {
        await saveEvent(
            eventName: name,
            eventStartDate: start,
            eventEndDate: end,
            isAllDay: allDay,
            selectedCalendar: selectedCalendar ?? petCalendar ?? .init("")
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
        guard let eventStore = eventStore as? EKEventStore else {
            Logger.events.error("Cannot create calendar: eventStore is not EKEventStore")
            return nil
        }
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = petCalendarTitle
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            calendar.source = defaultCalendar.source
        }
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            let petCalendar = EventCalendar(calendar.title)
            calendars.append(petCalendar)
            return petCalendar
        } catch {
            Logger.events.error("\(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Event Loading

    /// Loads events for the next month from all event calendars.
    /// - Returns: An array of events.
    func loadEvents() async -> [EKEvent] {
        let startDate: Date = .now
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
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
    ) async {
        let calendars = eventStore.calendars(for: .event)
        guard let petCalendar = calendars.first(where: { $0.title == selectedCalendar.title }) else {
            Logger.events.error("Event Save Error, Pet Calendar have not been found.")
            return
        }

        guard let eventStore = eventStore as? EKEventStore else {
            Logger.events.error("Event Save Error, eventStore is not EKEventStore")
            return
        }

        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = eventName
        newEvent.isAllDay = isAllDay
        newEvent.startDate = Calendar.current.date(byAdding: .minute, value: -10, to: eventStartDate)
        newEvent.endDate = isAllDay ? eventStartDate : eventEndDate
        newEvent.calendar = petCalendar

        let alarm = EKAlarm(
            absoluteDate: Calendar.current.date(byAdding: .minute, value: -10, to: .now) ?? .now
        )
        newEvent.addAlarm(alarm)
        newEvent.notes = "Pet Event"

        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
        } catch let error {
            if let error = error as? EKError {
                Logger.events.error("Event Save Error, \(error.errorCode): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Event Reloading

    /// Refreshes authorization status, calendar list, and loads events.
    func reloadEvents() async {
        await updateAuthStatus()
        await fetchCalendars()
        self.events = await loadEvents()
    }
}
