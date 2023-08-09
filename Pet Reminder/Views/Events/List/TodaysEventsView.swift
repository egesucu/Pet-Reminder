//
//  TodaysEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct TodaysEventsView: View {

    var eventVM: EventManager
    
    @Binding var filteredCalendar: EKCalendar?

    var filteredEvents: [EKEvent] {
        withAnimation {
            eventVM.events.filter {
                if let filteredCalendar {
                    return Calendar.current.isDateInToday($0.startDate) &&
                    $0.calendar == filteredCalendar
                } else {
                    return Calendar.current.isDateInToday($0.startDate)
                }
            }
        }
    }

    var body: some View {
        Section {
            if filteredEvents.isEmpty {
                Text("event_no_title")
            } else {
                ForEach(filteredEvents, id: \.eventIdentifier) { event in
                    EventView(event: event, eventVM: eventVM)
                        .padding(.horizontal, 5)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text("today_title")
        }
    }
}

#Preview {
    TodaysEventsView(eventVM: .init(isDemo: true), filteredCalendar: .constant(nil))
}
