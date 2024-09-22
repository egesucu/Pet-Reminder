//
//  AddEventView.swift
//  AddEventView
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import OSLog

struct AddEventView: View {

    @Binding var eventVM: EventViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var filteredCalendars: [EKCalendar] = []

    let feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text(
                        "add_event_info"
                    )
                ) {
                    TextField(text: $eventVM.eventName) {
                        Text("add_event_name")
                    }
                    Picker(selection: $eventVM.selectedCalendar) {
                        ForEach(filteredCalendars, id: \.calendarIdentifier) {
                            Text($0.title)
                                .tag($0)
                        }
                    } label: {
                        Text("add_event_calendar")
                    }
                    .onChange(of: eventVM.selectedCalendar) {
                        Logger
                            .events
                            .info("Selected Calendar: \(eventVM.selectedCalendar.title)")
                    }
                }
                Section(
                    header: Text(
                        "add_event_time"
                    )
                ) {
                    Toggle(isOn: $eventVM.isAllDay) {
                        Text("all_day_title")
                    }
                    eventDateView()
                }
            }
            .tint(.accent)
            .navigationTitle(
                Text(
                    "add_event_title"
                )
            )
            .toolbar(content: addEventToolbar)
        }
        .task {
            filteredCalendars = await eventVM.filteredCalendars()
        }
    }

    @ViewBuilder
    func eventDateView() -> some View {
        if eventVM.isAllDay {
            DatePicker(selection: $eventVM.eventStartDate, displayedComponents: .date) {
                Text("add_event_date")
            }
        } else {
            DatePicker(selection: $eventVM.eventStartDate) {
                Text("add_event_start")
            }
            .onChange(of: eventVM.eventStartDate, changeEventMinimumDate)
            DatePicker(selection: $eventVM.eventEndDate) {
                Text("add_event_end")
            }
        }
    }

    @ToolbarContentBuilder
    func addEventToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading, content: cancelButton)
        ToolbarItem(placement: .topBarTrailing, content: saveButton)
    }

    private func changeEventMinimumDate() {
        eventVM.eventEndDate = eventVM.eventStartDate.addingTimeInterval(60*60)
    }

    private func saveButton() -> some View {
        Button(action: saveEvent) {
            Text("add_event_save")
                .foregroundStyle(.accent)
                .bold()
        }
    }

    private func cancelButton() -> some View {
        Button(action: dismiss.callAsFunction) {
            Text("cancel")
        }
        .foregroundStyle(Color.red)
        .bold()
    }

    private func saveEvent() {
        feedback.notificationOccurred(.success)
        Task {
            await eventVM.saveEvent()
            dismiss()
        }
    }

}

#Preview {
    AddEventView(eventVM: .constant(.init(isDemo: true)))
}
