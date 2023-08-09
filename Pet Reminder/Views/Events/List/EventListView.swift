//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct EventListView: View {

    var eventVM = EventManager()
    @State private var showAddEvent = false
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    var body: some View {

        NavigationStack {
            showEventView()
                .navigationTitle(Text("event_title"))
                .toolbar(content: eventToolBar)

        }
        .navigationViewStyle(.stack)
        .onAppear(perform: reloadEvents)
    }

    @ToolbarContentBuilder
    func eventToolBar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: toggleAddEvent) {
                Label("add_event_accessible_title", systemImage: SFSymbols.calendar)
                    .font(.title2)
                    .foregroundColor(tintColor)
            }
            .sheet(isPresented: $showAddEvent, onDismiss: reloadEvents, content: { AddEventView() })
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

    @ViewBuilder
    func showEventView() -> some View {
        if eventVM.events.isEmpty {
            EmptyPageView(onRefreshEvents: reloadEvents, emptyPageReference: .events)
        } else {
            EventsView(eventVM: eventVM)
        }
    }

}

#Preview {
    EventListView(eventVM: .init(isDemo: true))
}
