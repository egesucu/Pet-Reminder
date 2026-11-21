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
import Combine

@MainActor
public struct EventList: View {

    public init() {}

    @Environment(EventManager.self) private var eventManager
    @Environment(\.scenePhase) private var scenePhase
    @SceneStorage("events.calendar") private var storedCalendar = ""
    @SceneStorage("events.selection") private var storedEventID = ""
    @SceneStorage("events.occurrence") private var storedOccurrence: Double = 0
    @State private var hasRestored = false
    @State private var showAddEvent = false
    @State private var selectedEvent: EKEvent?

    public var body: some View {
        NavigationSplitView {
            Group {
                switch eventManager.status {
                case .authorized:
                    Events(selectedEvent: $selectedEvent, addEvent: toggleAddEvent)
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
            .scrollContentBackground(.hidden)
            .background(Color.groupedBackground)
            .containerBackground(Color.groupedBackground, for: .navigation)
            .toolbarBackground(Color.groupedBackground, for: .navigationBar)
            .navigationTitle(Text(SharedStrings.eventTitle))
            .navigationBarTitleDisplayMode(.large)
            .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 460)
            .environment(eventManager)
        } detail: {
            Group {
                if let selectedEvent {
                    EventDetail(event: selectedEvent, onComplete: onDismiss)
                } else {
                    ContentUnavailableView(
                        SharedStrings.resource("Select an event"),
                        systemImage: "calendar",
                        description: Text(SharedStrings.resource("Choose an event to see its details."))
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.groupedBackground)
            .containerBackground(Color.groupedBackground, for: .navigation)
            .toolbarBackground(Color.groupedBackground, for: .navigationBar)
        }
        .navigationSplitViewStyle(.balanced)
        .containerBackground(Color.groupedBackground, for: .navigationSplitView)
        .background(Color.groupedBackground.ignoresSafeArea())
        .toolbarBackground(Color.groupedBackground, for: .tabBar)
        .sheet(isPresented: $showAddEvent, onDismiss: onDismiss) {
            AddEvent()
                .environment(eventManager)
        }
        .task(reloadEvents)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { onDismiss() }
        }
        .onChange(of: eventManager.selectedCalendar) { _, calendar in
            if hasRestored {
                storedCalendar = calendar?.id ?? AgendaRules.allCalendarsID
                selectedEvent = eventManager.reconciledEvent(selectedEvent)
            }
        }
        .onChange(of: selectedEvent) { _, event in
            storedEventID = event?.calendarItemIdentifier ?? ""
            storedOccurrence = event?.occurrenceDate?.timeIntervalSince1970 ?? 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in onDismiss() }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in onDismiss() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in onDismiss() }
    }

    func reloadEvents() async {
        await eventManager.reloadEvents()
        guard eventManager.status == .authorized else { return }
        if !hasRestored {
            if !storedCalendar.isEmpty {
                eventManager.selectedCalendar = eventManager.calendars.first { $0.id == storedCalendar }
            }
            hasRestored = true
            storedCalendar = eventManager.selectedCalendar?.id ?? AgendaRules.allCalendarsID
            selectedEvent = (eventManager.todaysEvents + eventManager.futureEvents).first {
                $0.calendarItemIdentifier == storedEventID && ($0.occurrenceDate?.timeIntervalSince1970 ?? 0) == storedOccurrence
            }
        } else {
            selectedEvent = eventManager.reconciledEvent(selectedEvent)
        }
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
            .keyboardShortcut("n")
            .disabled(showAddEvent)
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
