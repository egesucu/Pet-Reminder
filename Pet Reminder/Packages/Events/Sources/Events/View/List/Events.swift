//
//  Events.swift
//  Events
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI
import EventKit

struct Events: View {
    @Environment(EventManager.self) private var manager
    @Binding var selectedEvent: EKEvent?
    var addEvent: () -> Void = {}

    var body: some View {
        if manager.status == .authorized {
            List(selection: $selectedEvent) {
                if manager.todaysEvents.isEmpty && manager.futureEvents.isEmpty {
                    ContentUnavailableView {
                        Label(SharedStrings.resource("No upcoming events"), systemImage: "calendar")
                    } description: {
                        Text(SharedStrings.resource("Showing events from today through the next month."))
                    } actions: {
                        Button(action: addEvent) { Text(SharedStrings.addEventAccessibleTitle) }
                            .buttonStyle(.borderedProminent)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    TodaysEvents()
                    FutureEvents()
                }
                if !manager.todaysEvents.isEmpty || !manager.futureEvents.isEmpty {
                    Section {
                        Text(SharedStrings.resource("Showing events from today through the next month."))
                            .font(.footnote).foregroundStyle(.secondary)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .refreshable(action: reloadEvents)
        }
    }
}

// MARK: - Helpers
private extension Events {

    func reloadEvents() async {
        await manager.reloadEvents()
        selectedEvent = manager.reconciledEvent(selectedEvent)
    }
}

#if DEBUG
#Preview {
    Events(selectedEvent: .constant(nil))
        .environment(EventManager.demo)
}
#endif
