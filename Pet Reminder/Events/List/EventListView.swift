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

    @State private var eventVM = EventManager()
    @State private var showAddEvent = false
    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    var body: some View {

        NavigationStack {
            showEventView()
                .navigationTitle(Text("event_title"))
                .toolbar(content: eventToolBar)
        }
        .navigationViewStyle(.stack)
        .task(eventVM.reloadEvents)
    }

    @ToolbarContentBuilder
    func eventToolBar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: toggleAddEvent) {
                Label("add_event_accessible_title", systemImage: SFSymbols.calendar)
                    .font(.title2)
                    .foregroundStyle(tintColor)
            }
            .sheet(isPresented: $showAddEvent, onDismiss: {
                Task {
                   await eventVM.reloadEvents()
                }
            }, content: { AddEventView(eventVM: $eventVM) })
        }
    }

    private func toggleAddEvent() {
        showAddEvent.toggle()
    }

    @ViewBuilder
    func showEventView() -> some View {
        if eventVM.authorizationGiven {
            EventsView(eventVM: $eventVM)
        } else {
            EmptyPageView(emptyPageReference: .events)
        }
    }

}

#Preview {
    EventListView()
}
