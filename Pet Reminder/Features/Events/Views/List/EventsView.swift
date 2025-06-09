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
import Shared


struct EventsView: View {

    @Binding var eventVM: EventViewModel
    @Binding var selectedCalendar: EventCalendar?

    @State private var dates = [Date]()
    
    var body: some View {
        if eventVM.status == .authorized {
            List {
                TodaysEventsView(eventVM: $eventVM, selectedCalendar: $selectedCalendar)
                    .transition(.slide)
                FutureEventsView(eventVM: $eventVM, selectedCalendar: $selectedCalendar)
                    .transition(.slide)
            }
            .onAppear(perform: getEventDates)
            .refreshable {
                await eventVM.reloadEvents()
            }
            .overlay(alignment: .bottom) {
                VStack {
                    Spacer()
                    Text("Selected Calendar: \(selectedCalendar?.title ?? String(localized: "All"))")
                        .font(.footnote)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.capsule)
                        .frame(height: 60)
                }
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
    EventsView(eventVM: .constant(.init(isDemo: true)), selectedCalendar: .constant(nil))
}
