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
    
    @Binding var eventVM: EventManager
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    
    let feedback = UINotificationFeedbackGenerator()
    
    var filteredCalendars: [EKCalendar] {
        return eventVM
            .calendars
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
                                .tag($0)
                        }
                    }
                    .onChange(of: eventVM.selectedCalendar) {
                        Logger
                            .events
                            .info("Selected Calendar: \(eventVM.selectedCalendar.title)")
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
        ToolbarItem(placement: .topBarLeading, content: cancelButton)
        ToolbarItem(placement: .topBarTrailing, content: saveButton)
    }
    
    private func changeEventMinimumDate() {
        eventVM.eventEndDate = eventVM.eventStartDate.addingTimeInterval(60*60)
    }
    
    private func saveButton() -> some View {
        Button(action: saveEvent) {
            Text("add_event_save")
                .foregroundStyle(tintColor)
                .bold()
        }
    }
    
    private func cancelButton() -> some View {
        Button("cancel", action: dismiss.callAsFunction)
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
