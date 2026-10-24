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
        .onChange(of: eventManager.selectedCalendar) { _, _ in
            selectedEvent = eventManager.reconciledEvent(selectedEvent)
        }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in onDismiss() }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in onDismiss() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in onDismiss() }
    }

    func reloadEvents() async {
        await eventManager.reloadEvents()
        selectedEvent = eventManager.reconciledEvent(selectedEvent)
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
