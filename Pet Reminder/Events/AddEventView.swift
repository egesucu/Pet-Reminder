//
//  AddEventView.swift
//  AddEventView
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct AddEventView: View {

    @State var eventVM = EventManager()
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    let feedback = UINotificationFeedbackGenerator()
    
    var filteredCalendars: [EKCalendar] {
        return eventVM.calendars
            .filter { $0.allowsContentModifications }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("add_event_info")) {
                    TextField("add_event_name", text: $eventVM.eventName)
                    Picker("add_event_calendar", selection: $eventVM.selectedCalendar) {
                        ForEach(filteredCalendars, id: \.calendarIdentifier) {
                            Text($0.title)
                        }
                    }
                }
                Section(header: Text("add_event_time")) {
                    Toggle("all_day_title", isOn: $eventVM.isAllDay)
                    eventDateView()
                }
            }
            .tint(tintColor)
            .navigationTitle(Text("add_event_title"))
            .toolbar(content: addEventToolbar)
        }
    }

    @ViewBuilder
    func eventDateView() -> some View {
        if eventVM.isAllDay {
            DatePicker("add_event_date", selection: $eventVM.allDayDate, displayedComponents: .date)
        } else {
            DatePicker("add_event_start", selection: $eventVM.eventStartDate)
                .onChange(of: eventVM.eventStartDate, changeEventMinimumDate)
            DatePicker("add_event_end", selection: $eventVM.eventEndDate)
        }
    }

    @ToolbarContentBuilder
    func addEventToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            saveButton()
        }
    }

    private func changeEventMinimumDate() {
        eventVM.eventEndDate = eventVM.eventStartDate.addingTimeInterval(60*60)
    }

    func saveButton() -> some View {
        Button(action: saveEvent) {
            Text("add_event_save")
                .foregroundColor(tintColor)
                .bold()
        }
    }

    private func saveEvent() {
        feedback.notificationOccurred(.success)
        Task {
            await eventVM.saveEvent(onFinish: dismiss.callAsFunction)
        }
    }

}

#Preview {
    AddEventView()
}
