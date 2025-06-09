//
//  TodaysEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import OSLog
import Shared

struct TodaysEventsView: View {

    @Binding var eventVM: EventViewModel
    @Binding var selectedCalendar: EventCalendar?
    
    @State private var todaysEvents: [EKEvent] = []

    var body: some View {
        Section {
            if todaysEvents.isEmpty {
                Text("event_no_title")
            } else {
                ForEach(todaysEvents, id: \.self) { event in
                    EventView(event: event, eventVM: eventVM)
                        .padding(.horizontal, 5)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text("today_title")
        }
        .onChange(of: eventVM.events) {
            recalculateEvents()
        }
        .onChange(of: selectedCalendar) {
            recalculateEvents()
        }
        .onAppear {
            recalculateEvents()
        }
    }
    
    private func recalculateEvents() {
        Logger.events.info("Recalculating today's events")
        withAnimation {
            if let selected = selectedCalendar {
                todaysEvents = eventVM.events.filter {
                    Calendar.current.isDateInToday($0.startDate) && $0.calendar.title == selected.title
                }
            } else {
                todaysEvents = eventVM.events.filter {
                    Calendar.current.isDateInToday($0.startDate)
                }
            }
        }
    }
}

#Preview {
    TodaysEventsView(
        eventVM: .constant(.init(isDemo: true)),
        selectedCalendar: .constant(nil)
    )
}
