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
    @State private var dates = [Date]()

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
            .refreshable {
                await manager.reloadEvents()
            }
            .overlay(alignment: .bottom) {
                VStack {
                    Spacer()
                    Text("Selected Calendar: \(manager.selectedCalendar?.title ?? String(localized: .all))")
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
        let events = manager.events
        let eventDates = events.compactMap(\.startDate)
        self.dates = eventDates.removeDuplicates().sorted()
    }
}

#Preview {
    EventsView()
        .environment(EventManager.demo)
}
