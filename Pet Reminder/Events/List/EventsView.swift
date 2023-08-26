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

    var eventVM: EventManager

    @State private var dates = [Date]()
    @State private var filteredCalendar: EKCalendar?

    var body: some View {
        List {
            EventFilterView(eventVM: eventVM, filteredCalendar: $filteredCalendar)
                .transition(.slide)
            TodaysEventsView(eventVM: eventVM, filteredCalendar: $filteredCalendar)
                .transition(.slide)
            FutureEventsView(eventVM: eventVM, filteredCalendar: $filteredCalendar)
                .transition(.slide)
        }

        .onAppear(perform: getEventDates)
        .refreshable(action: eventVM.reloadEvents)
    }

    private func getEventDates() {
        let events = eventVM.events
        let eventDates = events.compactMap(\.startDate)
        self.dates = eventDates.removeDuplicates().sorted()
        makePetCalendarDefault()
    }

    private func makePetCalendarDefault() {
        if let petCalendar = eventVM.calendars.first(where: { $0.title == Strings.petReminder }) {
            filteredCalendar = petCalendar
        }
    }
}

#Preview {
    EventsView(eventVM: .init(isDemo: true))
}
