//
//  EventViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
import Observation
@preconcurrency import EventKit
import OSLog
import Shared

@MainActor
@Observable
class EventViewModel {

    var exampleEvents: [EKEvent] {
        var events: [EKEvent] = []
        (0...4).forEach { index in
            let event = EKEvent(eventStore: self.eventStore)
            event.title = Strings.demoEvent(index + 1)
            event.startDate = .now
            event.endDate = .now.addingTimeInterval(60)
            events.append(event)
        }
        return events
    }

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

    var events: [EKEvent] = []
    var calendars: [EventCalendar] = []
    var selectedCalendar: EventCalendar?
    var petCalendar: EventCalendar?
    var eventName = ""
    var eventStartDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
    var eventEndDate: Date = Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now
    var isAllDay = false
    var status: Status = .notDetermined

    @ObservationIgnored let eventStore = EKEventStore()

    init(isDemo: Bool = false) {
        if isDemo {
            events = exampleEvents
        } else {
            Task { [weak self] in
                guard let self else { return }
                await self.requestCalendarAccess()
            }
        }
    }

    @MainActor
    private func updateAuthStatus() async {
        status = .value(status: EKEventStore.authorizationStatus(for: .event))
        Logger.events.info("Auth status is: \(self.status.rawValue)")
    }

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

    func fillEventData(event: EKEvent) -> String {
        if Calendar.current.isDateInToday(event.startDate) {
            return String.formatEventDateTime(current: true, allDay: event.isAllDay, event: event)
        } else {
            return String.formatEventDateTime(current: false, allDay: event.isAllDay, event: event)
        }
    }

    @MainActor
    func fetchCalendars() async {
        if status == .authorized {
            self.calendars = eventStore.calendars(for: .event).map(\.title).map(EventCalendar.init)
            await definePetCalendar()
        }
    }

    @MainActor
    func definePetCalendar() async {
        petCalendar = await findOrCreatePetCalendar()
    }

    @MainActor
    func saveEvent() async {
        await saveEvent(
            eventName: eventName,
            eventStartDate: eventStartDate,
            eventEndDate: eventEndDate,
            isAllDay: isAllDay,
            selectedCalendar: petCalendar ?? .init("")
        )
    }

    func findOrCreatePetCalendar() async -> EventCalendar? {
        if let petCalendar = calendars.first(where: { $0.title == "Pet Reminder" }) {
            return petCalendar
        } else {
            return await createCalendar()
        }
    }

    private func createCalendar() async -> EventCalendar? {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "Pet Reminder"
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

        guard let petCalendar = eventStore
            .calendars(for: .event)
            .first(
                where: {
                    $0.title == selectedCalendar.title
                }) else {
            Logger.events.error("Event Save Error, Pet Calendar have not been found.")
            return
        }

        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = eventName
        newEvent.isAllDay = isAllDay
        newEvent.startDate = eventStartDate
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

    @MainActor
    func reloadEvents() async {
        await updateAuthStatus()
        await fetchCalendars()
        self.events = await loadEvents()
    }
}
