//
//  EventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct EventView: View {
    
    var event: EKEvent
    @State private var eventTitle = ""
    @State private var dateString = ""
    @State private var isShowing = false
    @State private var showWarningForCalendar = false
    
    var eventVM: EventManager
    
    var body: some View {
        HStack {
            if event.isAllDay {
                allDayEvent(event: event)
            } else {
                futureEvent(event: event)
            }
        }
        .sheet(isPresented: $showWarningForCalendar,
               onDismiss: onSheetDismiss,
               content: showEventDetail)
    }
    
    @ViewBuilder
    private func allDayEvent(event: EKEvent) -> some View {
        if Calendar.current.isDateInToday(event.startDate) {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 4)
                .foregroundStyle(Color(cgColor: event.calendar.cgColor))
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        } else {
            Text(event.startDate.formatted(.dateTime.day().month()))
                .foregroundStyle(Color(cgColor: event.calendar.cgColor))
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        }
    }
    
    @ViewBuilder
    private func futureEvent(event: EKEvent) -> some View {
        if Calendar.current.isDateInToday(event.startDate) {
            Text(event.startDate.formatted(.dateTime.hour().minute()))
                .padding(.trailing, 5)
                .foregroundStyle(Color(cgColor: event.calendar.cgColor))
            Text(event.title)
                .underline(true)
                .onTapGesture(perform: showWarning)
        } else {
            Text(event.startDate.formatted(.dateTime.day().month()))
                .padding(.trailing, 5)
                .foregroundStyle(Color(cgColor: event.calendar.cgColor))
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
        fillData()
        Task {
            await eventVM.reloadEvents()
        }
    }
    
    private func showWarning() {
        self.showWarningForCalendar.toggle()
    }
    
    private func fillData() {
        self.eventTitle = event.title
        eventVM.fillEventData(event: event) { content in
            DispatchQueue.main.async {
                self.dateString = content
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let manager = EventManager(isDemo: true)
    let event = manager.exampleEvents[0]
    return EventView(event: event, eventVM: manager)
        .frame(height: 100)
        .padding()
}
