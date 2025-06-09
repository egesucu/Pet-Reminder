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

    @Binding var eventVM: EventViewModel
    @Binding var selectedCalendar: EventCalendar?

    var filteredEvents: [EKEvent] {
        eventVM.events.filter {
            if let selectedCalendar {
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
                    EventView(event: event, eventVM: eventVM)
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
    FutureEventsView(
        eventVM: .constant(.init(isDemo: true)),
        selectedCalendar: .constant(nil)
    )
}
