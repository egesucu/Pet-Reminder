//
//  EventManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
import Observation
import EventKit

@Observable
class EventManager {

    var events: [EKEvent] = []
    var calendars: [EKCalendar] = []
    var selectedCalendar = EKCalendar(for: .event, eventStore: .init())
    var petCalendar: EKCalendar?
    var eventName = ""
    var allDayDate: Date = .now
    var eventStartDate: Date = .now
    var eventEndDate: Date = .now.addingTimeInterval(60*60)
    var isAllDay = false

    @ObservationIgnored let eventStore = EKEventStore()

    init() {
        requestEvents()
    }

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
            event.startDate = Date()
            event.endDate = Date()
            events.append(event)
        }
        return events
    }

    func requestEvents() {
        eventStore.requestFullAccessToEvents { success, error in
            if let error {
                print(error)
            } else if success {
                self.fetchCalendars()
            }
        }
    }

    func fetchCalendars() {
        self.calendars = eventStore.calendars(for: .event)
        setPetCalendar()
    }

    func setPetCalendar() {
        if let petCalendar = calendars.first(where: { $0.title == Strings.petReminder }) {
            self.petCalendar = petCalendar
            self.loadEvents()
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
            print(error.localizedDescription)
        }
    }

    func loadEvents() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .fullAccess {
            let startDate: Date = .now
            let endDate = Date(timeIntervalSinceNow: oneMonthInMilliSeconds)
            DispatchQueue.main.async {
                let predicate = self.eventStore.predicateForEvents(
                    withStart: startDate,
                    end: endDate,
                    calendars: self.calendars
                )
                self.events = self.eventStore.events(matching: predicate)
            }
        } else {
            requestEvents()
        }
    }

    func fillEventData(event: EKEvent, onCreated: (String) -> Void) {
        if Calendar.current.isDateInToday(event.startDate) {
            onCreated(String.formatEventDateTime(current: true, allDay: event.isAllDay, event: event))
        } else {
            onCreated(String.formatEventDateTime(current: false, allDay: event.isAllDay, event: event))
        }
    }

    @Sendable
    func reloadEvents() async {
        self.loadEvents()
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
            print(error.localizedDescription)
        }

    }

    func saveEvent(onFinish: () -> Void) async {

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
            await reloadEvents(onFinish: onFinish)
        } catch {
            print(error.localizedDescription)
        }
    }

    func reloadEvents(onFinish: () -> Void) async {
        await reloadEvents()
        onFinish()
    }
}
