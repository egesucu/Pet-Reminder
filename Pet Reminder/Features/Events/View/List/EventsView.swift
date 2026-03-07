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
    @Environment(EventManager.self) private var manager
    @State private var dates: [Date] = []

    var body: some View {
        if manager.status == .authorized {
            List {
                TodaysEventsView()
                    .environment(manager)
                    .transition(.slide)
                FutureEventsView()
                    .environment(manager)
                    .transition(.slide)
            }
            .onAppear(perform: getEventDates)
            .refreshable(action: reloadEvents)
        }
    }
}

// MARK: - Helpers
private extension EventsView {
    
    func reloadEvents() async {
        await manager.reloadEvents()
    }
    
    func getEventDates() {
        let events = manager.events
        let eventDates = events.compactMap(\.startDate)
        self.dates = eventDates.removeDuplicates().sorted()
    }
    
}

#if DEBUG
#Preview {
    EventsView()
        .environment(EventManager.demo)
}
#endif
