//
//  EventsView.swift
//  EventsView
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Foundation

struct EventsView: View {

    var eventVM: EventManager

    @State private var dates = [Date]()

    var body: some View {
        List {
            TodaysEventsView(eventVM: eventVM)
            FutureEventsView(eventVM: eventVM)
        }
        .onAppear(perform: getEventDates)
        .refreshable(action: eventVM.reloadEvents)
    }

    private func getEventDates() {
        let events = eventVM.events
        let eventDates = events.compactMap(\.startDate)
        self.dates = eventDates.removeDuplicates().sorted()
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(eventVM: .init(isDemo: true))
    }
}
