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

extension EKEventStore: @unchecked @retroactive Sendable {}

@MainActor
@Observable
class EventViewModel {
    
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
    var petCalendar: EKCalendar?
    var eventName = ""
    var eventStartDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
    var eventEndDate: Date = Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now
    var isAllDay = false
    var status: Status = .notDetermined
    
    @ObservationIgnored let eventStore = EKEventStore()
    
    private let eventDataActor: EventDataActor
    
    init(isDemo: Bool = false) {
        eventDataActor = EventDataActor(eventStore: eventStore)
        if isDemo {
            events = exampleEvents
        }
    }
    
    func getCalendars() async -> [EKCalendar] {
        await eventDataActor.getCalendars()
    }
    
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
    
    @MainActor
    private func updateAuthStatus() async {
        status = .value(status: EKEventStore.authorizationStatus(for: .event))
        Logger.events.info("Auth status is: \(self.status.rawValue)")
    }
    
    func requestEvents() async {
        let result = (try? await eventStore.requestFullAccessToEvents()) ?? false
        if result {
            await self.fetchCalendars()
        } else {
            self.status = .denied
        }
        await updateAuthStatus()
    }
    
    @MainActor
    func loadEvents() async {
        await updateAuthStatus()
        events.removeAll()
        if status == .authorized {
            events = await eventDataActor.loadEvents()
        } else {
            await requestEvents()
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
    func reloadEvents() async {
        await updateAuthStatus()
        await loadEvents()
        await fetchCalendars()
    }
    
    @MainActor
    func fetchCalendars() async {
        if status == .authorized {
            await eventDataActor.fetchCalendars()
            await setPetCalendar()
        }
    }
    
    @MainActor
    func setPetCalendar() async {
        petCalendar = await eventDataActor.findOrCreatePetCalendar()
    }
    
    @MainActor
    func saveEvent() async {
        await eventDataActor.saveEvent(
            eventName: eventName,
            eventStartDate: eventStartDate,
            eventEndDate: eventEndDate,
            isAllDay: isAllDay,
            selectedCalendar: petCalendar ?? .init()
        )
        await loadEvents()
    }
}
