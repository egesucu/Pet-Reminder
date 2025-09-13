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

    @Environment(EventManager.self) private var manager

    @State private var todaysEvents: [EKEvent] = []

    var body: some View {
        Section {
            if todaysEvents.isEmpty {
                Text(.eventNoTitle)
            } else {
                ForEach(todaysEvents, id: \.self) { event in
                    EventView(event: event)
                        .environment(manager)
                        .padding(.horizontal, 5)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text(.todayTitle)
        }
        .onChange(of: manager.events) {
            recalculateEvents()
        }
        .onChange(of: manager.selectedCalendar) {
            recalculateEvents()
        }
        .onAppear {
            recalculateEvents()
        }
    }

    private func recalculateEvents() {
        Logger.events.info("Recalculating today's events")
        withAnimation {
            if let selected = manager.selectedCalendar {
                todaysEvents = manager.events.filter { event in
                    Calendar.current.isDateInToday(event.startDate) && event.calendar.title == selected.title
                }
            } else {
                todaysEvents = manager.events.filter {
                    Calendar.current.isDateInToday($0.startDate)
                }
            }
        }
    }
}

#Preview {
    TodaysEventsView()
        .environment(EventManager.demo)
}
