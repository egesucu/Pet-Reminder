//
//  FutureEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import SharedModels

public struct FutureEventsView: View {

    @Binding var eventVM: EventManager
    @Binding var filteredCalendar: EKCalendar?

    var filteredEvents: [EKEvent] {
        withAnimation {
            eventVM.events.filter {
                if let filteredCalendar {
                    return Calendar.current.isDateLater(date: $0.startDate) &&
                    $0.calendar == filteredCalendar
                } else {
                    return Calendar.current.isDateLater(date: $0.startDate)
                }
            }
        }

    }

    public var body: some View {
        Section {
            if filteredEvents.isEmpty {
                Text("event_no_title", bundle: .module)
            } else {
                ForEach(filteredEvents, id: \.self) { event in
                    EventView(event: event, eventVM: eventVM)
                        .padding(.horizontal, 5)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text("upcoming_title", bundle: .module)
        }
    }
}

#Preview {
    FutureEventsView(eventVM: .constant(.init(isDemo: true)), filteredCalendar: .constant(nil))
}
