//
//  EventsView.swift
//  EventsView
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import EventKit
import Foundation
import SwiftUI

struct EventsView: View {

  // MARK: Internal

  @Binding var eventVM: EventManager

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
      .task(eventVM.fetchCalendars)
      .onAppear(perform: getEventDates)
      .refreshable(action: eventVM.reloadEvents)
    }
  }

  // MARK: Private

  @State private var dates = [Date]()
  @State private var filteredCalendar: EKCalendar?

  private func getEventDates() {
    let events = eventVM.events
    let eventDates = events.compactMap(\.startDate)
    dates = eventDates.removeDuplicates().sorted()
  }
}

#Preview {
  EventsView(eventVM: .constant(.init(isDemo: true)))
}
