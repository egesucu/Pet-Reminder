//
//  EventList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared
import SharedUI
import OSLog

@MainActor
public struct EventList: View {

    public init() {}

    @Environment(EventManager.self) private var eventManager
    @State private var showAddEvent = false
    @State private var selectedEvent: EKEvent?

    public var body: some View {
        NavigationSplitView {
            Group {
                switch eventManager.status {
                case .authorized:
                    Events(selectedEvent: $selectedEvent)
                        .toolbar {
                            EventFilterMenu()
                            eventToolBar
                        }
                case .denied, .notDetermined:
                    eventNotAllowed
                case .readOnly:
                    wrongTypeError
                }
            }
            .navigationTitle(Text(SharedStrings.eventTitle))
            .environment(eventManager)
        } detail: {
            if let selectedEvent {
                ESEventDetail(event: selectedEvent)
                    .navigationTitle(selectedEvent.title)
            } else {
                ContentUnavailableView(
                    SharedStrings.resource("Select an event"),
                    systemImage: "calendar",
                    description: Text(SharedStrings.resource("Choose an event to see its details."))
                )
            }
        }
        .sheet(isPresented: $showAddEvent, onDismiss: onDismiss) {
            AddEvent()
                .environment(eventManager)
        }
        .task(reloadEvents)
    }

    func reloadEvents() async {
        await eventManager.reloadEvents()
    }

    @ContentBuilder var eventNotAllowed: some View {
        ContentUnavailableView {
            Label {
                Text(SharedStrings.eventErrorTitle)
            } icon: {
                Image(systemName: "calendar.badge.exclamationmark")
            }
        } description: {
            Text(SharedStrings.eventNotAllowed)
        } actions: {
            SettingsButton()
        }
    }

    @ContentBuilder var wrongTypeError: some View {
        ContentUnavailableView {
            Label {
                Text(SharedStrings.eventErrorTitle)
            } icon: {
                Image(systemName: "calendar.badge.exclamationmark")
            }
        } description: {
            Text(SharedStrings.eventWrongAllowence)
        } actions: {
            SettingsButton()
        }
    }

    @ContentBuilder var eventToolBar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: toggleAddEvent) {
                Label {
                    Text(SharedStrings.addEventAccessibleTitle)
                        .font(.title2)
                } icon: {
                    Image(systemName: "calendar.badge.plus")
                }
            }
            .tint(.accent)
        }
    }

    private func onDismiss() {
        Task {
            await reloadEvents()
        }
    }

    private func toggleAddEvent() {
        showAddEvent.toggle()
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        EventList()
            .environment(EventManager.demo)
    }

}
#endif
