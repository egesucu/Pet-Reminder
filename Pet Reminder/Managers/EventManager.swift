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

@Observable
class EventManager {

    var events: [EKEvent] = []
    var calendars: [EKCalendar] = []
    var selectedCalendar = EKCalendar(for: .event, eventStore: .init())
    var petCalendar: EKCalendar?
    var eventName = ""
    var allDayDate: Date = .now
    var eventStartDate: Date = .now.addingTimeInterval(60*60)
    var eventEndDate: Date = .now.addingTimeInterval(60*60*2)
    var isAllDay = false
    var authStatus: EventAuthenticationStatus = .notDetermined

    @ObservationIgnored let eventStore = EKEventStore()

    init(isDemo: Bool = false) {
        if isDemo {
            events = exampleEvents
        }
    }

    var exampleEvents: [EKEvent] {
        var events: [EKEvent] = []
        (0...4).forEach { index in
            let event = EKEvent(eventStore: self.eventStore)
            event.title = Strings.demoEvent(index+1)
            event.startDate = .now
            event.endDate = .now.addingTimeInterval(60)
            events.append(event)
        }
        return events
    }

    private func updateAuthStatus() async {
        await MainActor.run {
            self.authStatus = .value(status: EKEventStore.authorizationStatus(for: .event))
            Logger
                .events
                .info("Auth status is: \(self.authStatus.rawValue)")
        }
    }

    func requestEvents() async {
        do {
            let result = try await eventStore.requestFullAccessToEvents()
            if result {
                self.fetchCalendars()
            } else {
                self.authStatus = .denied
            }
            await updateAuthStatus()
        } catch let error {
            Logger
                .events
                .error("\(error)")
        }
    }

    func fetchCalendars() {
        if authStatus == .authorized {
            self.calendars = eventStore.calendars(for: .event)
            setPetCalendar()
        } else {
            calendars.removeAll()
        }
    }

    func setPetCalendar() {
        if let petCalendar = calendars.first(where: { $0.title == Strings.petReminder }) {
            self.petCalendar = petCalendar
            Task {
                await self.loadEvents()
            }
        } else {
            self.createCalendar()
        }
    }

    func createCalendar() {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = Strings.petReminder
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            calendar.source = defaultCalendar.source
        }
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            Logger
                .events
                .error("\(error)")
        }
    }

    func loadEvents() async {
        await updateAuthStatus()
        events.removeAll()
        if authStatus == .authorized {
            let startDate: Date = .now
            let endDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
            let predicate = self.eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: self.calendars
            )
            events = eventStore.events(matching: predicate)
        } else {
            Task {
                await requestEvents()
            }
        }
    }

    func fillEventData(event: EKEvent) -> String {
        if Calendar.current.isDateInToday(event.startDate) {
            String.formatEventDateTime(current: true, allDay: event.isAllDay, event: event)
        } else {
            String.formatEventDateTime(current: false, allDay: event.isAllDay, event: event)
        }
    }

    func reloadEvents() async {
        await updateAuthStatus()
        await loadEvents()
        self.fetchCalendars()
    }

    func convertDateToString(startDate: Date?, endDate: Date?) -> String {
        if let startDate = startDate {
            let start = startDate.formatted(date: .numeric, time: .standard)
            if let endDate = endDate {
                let end = endDate.formatted(date: .numeric, time: .standard)
                return "\(start) - \(end)"
            }
            return start
        }
        return ""
    }

    func removeEvent(event: EKEvent) {
        do {
            try self.eventStore.remove(event, span: .thisEvent, commit: true)
        } catch {
            Logger
                .events
                .error("\(error)")
        }

    }

    func saveEvent() async {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = eventName
        newEvent.isAllDay = isAllDay

        if isAllDay {
            newEvent.startDate = allDayDate
            newEvent.endDate = allDayDate
        } else {
            newEvent.startDate = eventStartDate
            newEvent.endDate = eventEndDate
        }

        newEvent.calendar = selectedCalendar

        let alarm = EKAlarm(relativeOffset: -60 * 10)
        newEvent.addAlarm(alarm)
        newEvent.notes = String(localized: "add_event_note")

        do {
            try eventStore.save(newEvent, span: .thisEvent)
        } catch let error {
            if let error = error as? EKError {
                Logger
                    .events
                    .error("Event Save Error, \(error.errorCode): \(error.localizedDescription)")
            }
        }
        await reloadEvents()

    }
}
