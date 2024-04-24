//
//  EventsView.swift
//  EventsView
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Foundation
import EventKit

struct EventsView: View {

    @Binding var eventVM: EventManager

    @State private var dates = [Date]()
    @State private var filteredCalendar: EKCalendar?

    var body: some View {
        if eventVM.authStatus == .authorized {
            List {
                EventFilterView(eventVM: $eventVM, filteredCalendar: $filteredCalendar)
                    .transition(.slide)
                TodaysEventsView(eventVM: $eventVM, filteredCalendar: $filteredCalendar)
                    .transition(.slide)
                FutureEventsView(eventVM: $eventVM, filteredCalendar: $filteredCalendar)
                    .transition(.slide)
            }
            .task {
                eventVM.fetchCalendars()
            }
            .onAppear(perform: getEventDates)
            .refreshable {
                await eventVM.reloadEvents()
            }
        }

    }

    private func getEventDates() {
        let events = eventVM.events
        let eventDates = events.compactMap(\.startDate)
        self.dates = eventDates.removeDuplicates().sorted()
    }
}

#Preview {
    EventsView(eventVM: .constant(.init(isDemo: true)))
}
