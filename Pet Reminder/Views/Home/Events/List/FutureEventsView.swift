//
//  FutureEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct FutureEventsView: View {

    var eventVM: EventManager

    var filteredEvents: [EKEvent] {
        eventVM.events.filter({ Calendar.current.isDateLater(date: $0.startDate) })
    }

    var body: some View {
        Section {
            ForEach(filteredEvents, id: \.eventIdentifier) { event in
                EventView(event: event, eventVM: eventVM)
                    .padding(.horizontal, 5)
                    .listRowSeparator(.hidden)
            }
        } header: {
            Text("upcoming_title")
        }
    }
}

#Preview {
    FutureEventsView(eventVM: .init(isDemo: true))
}
