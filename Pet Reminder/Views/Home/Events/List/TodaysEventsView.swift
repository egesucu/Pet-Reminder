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

    var filteredEvents: [EKEvent] {
        eventVM.events.filter({ Calendar.current.isDateInToday($0.startDate)})
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
    TodaysEventsView(eventVM: .init(isDemo: true))
}
