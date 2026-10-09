//
//  SingleEvent.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared

struct SingleEvent: View {

    var event: EKEvent

    var body: some View {
        HStack {
            if event.isAllDay {
                allDayEvent(event: event)
            } else {
                futureEvent(event: event)
            }
        }
    }

    @ContentBuilder
    private func allDayEvent(event: EKEvent) -> some View {
        if Calendar.current.isDateInToday(event.startDate) {
            RoundedRectangle(cornerRadius: .spacing4 / 2)
                .frame(width: .eventIndicatorWidth)
                .foregroundStyle(Color(cgColor: event.calendar.cgColor))
            Text(event.title)
            .frame(minHeight: 44)
        } else {
            Text(event.startDate.formatted(.dateTime.day().month()))
                .padding(.spacing4)
                .background(Color(cgColor: event.calendar.cgColor))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: .radius10))
                .padding(.trailing, .spacing4)
            Text(event.title)
            .frame(minHeight: 44)
        }
    }

    @ContentBuilder
    private func futureEvent(event: EKEvent) -> some View {
        if Calendar.current.isDateInToday(event.startDate) {
            Text(event.startDate.formatted(.dateTime.hour().minute()))
                .padding(.spacing4)
                .background(Color(cgColor: event.calendar.cgColor))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: .radius10))
                .padding(.trailing, .spacing4)
            Text(event.title)
            .frame(minHeight: 44)
        } else {
            Text(event.startDate.formatted(.dateTime.day().month()))
                .padding(.spacing4)
                .background(Color(cgColor: event.calendar.cgColor))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: .radius10))
                .padding(.trailing, .spacing4)
            Text(event.title)
            .frame(minHeight: 44)
        }
    }
}

#if DEBUG
#Preview("Daily Event", traits: .sizeThatFitsLayout) {
    let dummyStore = EKEventStore()
    let dummyEvent = EKEvent(eventStore: dummyStore)
    dummyEvent.title = "Checkup"
    dummyEvent.startDate = Date()
    dummyEvent.endDate = Date().addingTimeInterval(3600)
    dummyEvent.calendar = {
        let cal = EKCalendar(for: .event, eventStore: dummyStore)
        cal.title = "Vet"
        cal.cgColor = UIColor.systemBlue.cgColor
        return cal
    }()

    let dummyVM = EventManager.demo
    return SingleEvent(event: dummyEvent)
        .environment(dummyVM)
        .frame(height: .feedCardHeight100)
        .padding()
}

#Preview("Full Day Event", traits: .sizeThatFitsLayout) {
    let dummyStore = EKEventStore()
    let dummyEvent = EKEvent(eventStore: dummyStore)
    dummyEvent.title = "Checkup"
    dummyEvent.startDate = Date()
    dummyEvent.isAllDay = true
    dummyEvent.endDate = Date().addingTimeInterval(3600)
    dummyEvent.calendar = {
        let cal = EKCalendar(for: .event, eventStore: dummyStore)
        cal.title = "Vet"
        cal.cgColor = UIColor.systemBlue.cgColor
        return cal
    }()

    let dummyVM = EventManager.demo
    return SingleEvent(event: dummyEvent)
        .environment(dummyVM)
        .frame(height: .feedCardHeight100)
        .padding()
}
#endif
