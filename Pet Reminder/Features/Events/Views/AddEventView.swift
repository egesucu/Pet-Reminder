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
import Shared

struct AddEventView: View {

    @Environment(EventManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    @State private var eventName = ""
    @State private var allDay = false
    @State private var startDate: Date = Calendar.current.date(
        byAdding: .hour,
        value: 1,
        to: .now
    ) ?? .now
    @State private var endDate: Date = Calendar.current.date(
        byAdding: .hour,
        value: 2,
        to: .now
    ) ?? .now
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
                    TextField(text: $eventName) {
                        Text("add_event_name")
                    }
                }
                Section(
                    header: Text(
                        "add_event_time"
                    )
                ) {
                    Toggle(isOn: $allDay) {
                        Text("all_day_title")
                    }
                    eventDateView()
                }
            }
            .tint(.accent)
            .navigationTitle(
                Text("add_event_title")
            )
            .navigationBarTitleTextColor(.accent)
            .toolbar(content: addEventToolbar)
        }
    }

    @ViewBuilder
    func eventDateView() -> some View {
        if allDay {
            DatePicker(selection: $startDate, displayedComponents: .date) {
                Text("add_event_date")
            }
        } else {
            DatePicker(selection: $startDate) {
                Text("add_event_start")
            }
            .onChange(of: startDate, changeEventMinimumDate)
            DatePicker(selection: $endDate) {
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
        endDate = startDate.addingTimeInterval(60*60)
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
            await manager.saveEvent(
                name: eventName,
                start: startDate,
                end: endDate,
                allDay: allDay
            )
            dismiss()
        }
    }

}

#Preview {
    AddEventView()
        .environment(EventManager.demo)
}
