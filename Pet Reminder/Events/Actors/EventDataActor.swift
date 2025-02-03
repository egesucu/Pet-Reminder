//
//  EventDataActor.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 20.09.2024.
//  Copyright © 2024 Ege Sucu. All rights reserved.
//

import Foundation
import EventKit
import OSLog

actor EventDataActor {
    
    private var calendars: [EKCalendar] = []
    private let eventStore: EKEventStore
    
    init(eventStore: EKEventStore) {
        self.eventStore = eventStore
    }
    
    func getCalendars() -> [EKCalendar] {
        return calendars
    }
    
    func fetchCalendars() async {
        self.calendars = eventStore.calendars(for: .event)
    }
    
    func findOrCreatePetCalendar() async -> EKCalendar? {
        if let petCalendar = calendars.first(where: { $0.title == "Pet Reminder" }) {
            return petCalendar
        } else {
            return await createCalendar()
        }
    }
    
    private func createCalendar() async -> EKCalendar? {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "Pet Reminder"
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            calendar.source = defaultCalendar.source
        }
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            self.calendars.append(calendar)
            return calendar
        } catch {
            Logger.events.error("\(error.localizedDescription)")
            return nil
        }
    }
    
    func loadEvents() async -> [EKEvent] {
        let startDate: Date = .now
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        return eventStore.events(matching: predicate)
    }
    
    func saveEvent(
        eventName: String,
        eventStartDate: Date,
        eventEndDate: Date,
        isAllDay: Bool,
        selectedCalendar: EKCalendar
    ) async {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = eventName
        newEvent.isAllDay = isAllDay
        newEvent.startDate = eventStartDate
        newEvent.endDate = isAllDay ? eventStartDate : eventEndDate
        newEvent.calendar = selectedCalendar
        
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
}
