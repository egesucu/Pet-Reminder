//
//  FutureEvents.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared

struct FutureEvents: View {

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
                Text(.eventNoTitle)
            } else {
                ForEach(filteredEvents, id: \.self) { event in
                    SingleEvent(event: event)
                        .environment(manager)
                        .padding(.horizontal, .spacing4)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text(.upcomingTitle)
        }
    }
}

#if DEBUG
#Preview {
    FutureEvents()
        .environment(EventManager.demo)
}
#endif
