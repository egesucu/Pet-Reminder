//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit


struct EventListView: View {

    @State private var eventVM: EventViewModel
    @State private var showAddEvent = false
    

    init(eventVM: EventViewModel) {
        _eventVM = State(wrappedValue: eventVM)
    }

    var body: some View {
        NavigationStack {
            EventsView(eventVM: $eventVM)
        }
        .sheet(
            isPresented: $showAddEvent,
            onDismiss: reloadEvents
        ) {
            AddEventView(eventVM: $eventVM)
        }
        .toolbar(content: eventToolBar)
        .navigationTitle(Text("event_title"))
        .overlay(content: eventViewOverlay)
        .task {
            await eventVM.reloadEvents()
        }
    }

    @ViewBuilder
    func eventViewOverlay() -> some View {
        if eventVM.status == .denied {
            ContentUnavailableView(label: {
                Label {
                    Text("event_error_title")
                } icon: {
                    Image(systemName: "calendar.badge.exclamationmark")
                }
            }, description: {
                Text("event_not_allowed")
            }, actions: {
                ESSettingsButton()
            })
        } else if eventVM.status == .readOnly {
            ContentUnavailableView(label: {
                Label {
                    Text("event_error_title")
                } icon: {
                    Image(systemName: "calendar.badge.exclamationmark")
                }
            }, description: {
                Text("event_wrong_allowence")
            }, actions: {
                ESSettingsButton()
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
                    Image(systemName: SFSymbols.calendar)
                }
            }
        }
    }

    private func reloadEvents() {
        Task {
            await eventVM.reloadEvents()
        }
    }

    private func toggleAddEvent() {
        showAddEvent.toggle()
    }
}

#Preview {
    EventListView(eventVM: .init(isDemo: true))
}