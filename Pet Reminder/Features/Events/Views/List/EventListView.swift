//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared
import OSLog
import SFSafeSymbols

struct EventListView: View {

    @Environment(EventManager.self) private var eventManager
    @State private var showAddEvent = false

    var body: some View {
        NavigationStack {
            EventsView()
                .navigationTitle(Text(.eventTitle))
                .navigationBarTitleTextColor(.accent)
                .toolbar {
                        EventFilterMenu()
                        eventToolBar()
                }
                .environment(eventManager)
        }
        .sheet(
            isPresented: $showAddEvent,
            onDismiss: reloadEvents
        ) {
            AddEventView()
                .environment(eventManager)
        }
        .overlay {
            eventViewOverlay()
        }
        .task {
            await eventManager.reloadEvents()
        }
        .onChange(of: eventManager.selectedCalendar) { oldValue, newValue in
            Logger.events.info("Selected calendar has changed from \(String(describing: oldValue)) to \(String(describing: newValue))")
        }
    }

    @ViewBuilder
    func eventViewOverlay() -> some View {
        if eventManager.status == .denied {
            ContentUnavailableView(label: {
                Label {
                    Text("event_error_title")
                } icon: {
                    Image(systemName: "calendar.badge.exclamationmark")
                }
            }, description: {
                Text("event_not_allowed")
            }, actions: {
                SettingsButton()
            })
        } else if eventManager.status == .readOnly {
            ContentUnavailableView(label: {
                Label {
                    Text("event_error_title")
                } icon: {
                    Image(systemName: "calendar.badge.exclamationmark")
                }
            }, description: {
                Text(.eventWrongAllowence)
            }, actions: {
                SettingsButton()
            })
        }
    }

    @ToolbarContentBuilder
    func eventToolBar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: toggleAddEvent) {
                Label {
                    Text("add_event_accessible_title")
                        .font(.title2)
                        .foregroundStyle(.accent)
                } icon: {
                    Image(systemSymbol: SFSymbol.calendarBadgePlus)
                }
            }
        }
    }

    private func reloadEvents() {
        Task {
            await eventManager.reloadEvents()
        }
    }

    private func toggleAddEvent() {
        showAddEvent.toggle()
    }
}

#Preview {
    EventListView()
        .environment(EventManager.demo)
}
