//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import EventKit
import SwiftUI

struct EventListView: View {

  // MARK: Lifecycle

  init(eventVM: EventManager) {
    _eventVM = State(wrappedValue: eventVM)
  }

  // MARK: Internal

  @AppStorage(Strings.tintColor) var tintColor = Color.accent

  var body: some View {
    NavigationStack {
      EventsView(eventVM: $eventVM)
    }
    .sheet(
      isPresented: $showAddEvent,
      onDismiss: reloadEvents)
    {
      AddEventView(eventVM: $eventVM)
    }
    .toolbar(content: eventToolBar)
    .navigationTitle(Text("event_title"))
    .overlay(content: eventViewOverlay)
    .task(eventVM.reloadEvents)
  }

  @ViewBuilder
  func eventViewOverlay() -> some View {
    if eventVM.authStatus == .denied {
      ContentUnavailableView(label: {
        Label("event_error_title", systemImage: "calendar.badge.exclamationmark")
      }, description: {
        Text("event_not_allowed")
      }, actions: {
        ESSettingsButton()
      })
    } else if eventVM.authStatus == .readOnly {
      ContentUnavailableView(label: {
        Label("event_error_title", systemImage: "calendar.badge.exclamationmark")
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
        Label("add_event_accessible_title", systemImage: SFSymbols.calendar)
          .font(.title2)
          .foregroundStyle(tintColor)
      }
    }
  }

  // MARK: Private

  @State private var eventVM: EventManager
  @State private var showAddEvent = false

  private func reloadEvents() {
    Task {
      eventVM.reloadEvents
    }
  }

  private func toggleAddEvent() {
    showAddEvent.toggle()
  }
}

#Preview {
  EventListView(eventVM: .init(isDemo: true))
}
