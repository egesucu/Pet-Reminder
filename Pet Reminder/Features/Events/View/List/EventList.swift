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
import OSLog

struct EventList: View {
    
    @Environment(EventManager.self) private var eventManager
    @State private var showAddEvent = false
    
    var body: some View {
        NavigationStack {
            VStack {
                switch eventManager.status {
                case .authorized:
                    Events()
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
            .navigationTitle(Text(.eventTitle))
            .environment(eventManager)
        }
        .sheet(isPresented: $showAddEvent,onDismiss: onDismiss) {
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
                Text(.eventErrorTitle)
            } icon: {
                Image(systemName: "calendar.badge.exclamationmark")
            }
        } description: {
            Text(.eventNotAllowed)
        } actions: {
            SettingsButton()
        }
    }
    
    @ContentBuilder var wrongTypeError: some View {
        ContentUnavailableView {
            Label {
                Text(.eventErrorTitle)
            } icon: {
                Image(systemName: "calendar.badge.exclamationmark")
            }
        } description: {
            Text(.eventWrongAllowence)
        } actions: {
            SettingsButton()
        }
    }
    
    @ContentBuilder var eventToolBar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: toggleAddEvent) {
                Label {
                    Text(.addEventAccessibleTitle)
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
