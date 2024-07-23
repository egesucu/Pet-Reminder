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
import SharedModels

public struct AddEventView: View {

    @Binding var eventVM: EventManager
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    let feedback = UINotificationFeedbackGenerator()

    var filteredCalendars: [EKCalendar] {
        return eventVM
            .calendars
            .filter { $0.allowsContentModifications }
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text(
                        "add_event_info",
                        bundle: .module
                    )
                ) {
                    TextField(text: $eventVM.eventName) {
                        Text("add_event_name", bundle: .module)
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
                        "add_event_time",
                        bundle: .module
                    )
                ) {
                    Toggle(isOn: $eventVM.isAllDay) {
                        Text("all_day_title", bundle: .module)
                    }
                    eventDateView()
                }
            }
            .tint(tintColor.color)
            .navigationTitle(
                Text(
                    "add_event_title",
                    bundle: .module
                )
            )
            .toolbar(content: addEventToolbar)
        }
    }

    @ViewBuilder
    func eventDateView() -> some View {
        if eventVM.isAllDay {
            DatePicker(selection: $eventVM.allDayDate, displayedComponents: .date) {
                Text("add_event_date", bundle: .module)
            }
        } else {
            DatePicker(selection: $eventVM.eventStartDate) {
                Text("add_event_start", bundle: .module)
            }
            .onChange(of: eventVM.eventStartDate, changeEventMinimumDate)
            DatePicker(selection: $eventVM.eventEndDate) {
                Text("add_event_end", bundle: .module)
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
            Text("add_event_save", bundle: .module)
                .foregroundStyle(tintColor.color)
                .bold()
        }
    }

    private func cancelButton() -> some View {
        Button(action: dismiss.callAsFunction) {
            Text("cancel", bundle: .module)
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
