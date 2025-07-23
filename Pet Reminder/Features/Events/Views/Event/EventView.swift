//
//  EventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Playgrounds

struct EventView: View {

    var event: EKEvent
    @State private var eventTitle = ""
    @State private var dateString = ""
    @State private var isShowing = false
    @State private var showWarningForCalendar = false

    @Environment(EventManager.self) private var manager

    var body: some View {
        HStack {
            if event.isAllDay {
                allDayEvent(event: event)
            } else {
                futureEvent(event: event)
            }
        }
        .sheet(isPresented: $showWarningForCalendar,
               onDismiss: onSheetDismiss) {
            showEventDetail()
        }
    }

    @ViewBuilder
    private func allDayEvent(event: EKEvent) -> some View {
        if Calendar.current.isDateInToday(event.startDate) {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 6)
                .foregroundStyle(Color(cgColor: event.calendar.cgColor))
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        } else {
            Text(event.startDate.formatted(.dateTime.day().month()))
                .padding(.all, 5)
                .background(Color(cgColor: event.calendar.cgColor))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 5)
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        }
    }

    @ViewBuilder
    private func futureEvent(event: EKEvent) -> some View {
        if Calendar.current.isDateInToday(event.startDate) {
            Text(event.startDate.formatted(.dateTime.hour().minute()))
                .padding(.all, 5)
                .background(Color(cgColor: event.calendar.cgColor))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 5)
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        } else {
            Text(event.startDate.formatted(.dateTime.day().month()))
                .padding(.all, 5)
                .background(Color(cgColor: event.calendar.cgColor))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 5)
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        }
    }

    private func showEventDetail() -> some View {
        SheetContent(event: event)
            .presentationDetents([.medium])
            .presentationCornerRadius(10)
            .presentationDragIndicator(.visible)
    }
}

extension EventView {
    private func onSheetDismiss() {
        Task {
            await fillData()
            await manager.reloadEvents()
        }
    }

    private func showWarning() {
        self.showWarningForCalendar.toggle()
    }

    private func fillData() async {
        self.eventTitle = event.title
        let content = manager.formattedEventDateString(for: event)
        self.dateString = content
    }
}

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
    return EventView(event: dummyEvent)
        .environment(dummyVM)
        .frame(height: 100)
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
    return EventView(event: dummyEvent)
        .environment(dummyVM)
        .frame(height: 100)
        .padding()
}

// swiftlint: disable todo
// Broken with Xcode 26 Beta 3
// FIXME: Try this on later betas
// #Playground {
//    let manager = EventManager.demo
//    _ = manager.events
// }
// swiftlint: enable todo
