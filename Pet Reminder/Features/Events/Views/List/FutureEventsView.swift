//
//  FutureEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared

struct FutureEventsView: View {

    @Environment(EventManager.self) private var manager

    var filteredEvents: [EKEvent] {
        manager.events.filter {
            if let selectedCalendar = manager.selectedCalendar {
                return Calendar.current.isDateLater(date: $0.startDate) &&
                $0.calendar.title == selectedCalendar.title
            } else {
                return Calendar.current.isDateLater(date: $0.startDate)
            }
        }
    }

    var body: some View {
        Section {
            if filteredEvents.isEmpty {
                Text("event_no_title")
            } else {
                ForEach(filteredEvents, id: \.self) { event in
                    EventView(event: event)
                        .environment(manager)
                        .padding(.horizontal, 5)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text("upcoming_title")
        }
    }
}

#Preview {
    FutureEventsView()
        .environment(EventManager.demo)
}
