//
//  AddEventView.swift
//  AddEventView
//
//  Created by Ege Sucu on 11.09.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct AddEventView : View {
    
    @StateObject var eventVM = EventManager()
    @Environment(\.dismiss) var dismiss
    @AppStorage("tint_color") var tintColor = Color.systemGreen
    
    let feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("add_event_info")) {
                    TextField("add_event_name", text: $eventVM.eventName)
                }
                Section(header: Text("add_event_time")) {
                    Toggle("all_day_title", isOn: $eventVM.isAllDay)
                    eventDateView()
                }
            }
            .accentColor(tintColor)
            .navigationTitle(Text("add_event_title"))
            .toolbar(content: addEventToolbar)
        }
    }
    
    @ViewBuilder
    func eventDateView() -> some View {
        if eventVM.isAllDay{
            DatePicker("add_event_date", selection: $eventVM.allDayDate, displayedComponents: .date)
        } else {
            DatePicker("add_event_start", selection: $eventVM.eventStartDate)
                .onChange(of: eventVM.eventStartDate, perform: changeEventMinimumDate(_:))
            DatePicker(NSLocalizedString("add_event_end", comment: "") , selection: $eventVM.eventEndDate)
        }
    }
    
    @ToolbarContentBuilder
    func addEventToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            SaveButton()
        }
    }
    
    private func changeEventMinimumDate(_ value: Date) {
        eventVM.eventEndDate = value.addingTimeInterval(60*60)
    }
    
    func SaveButton() -> some View {
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

struct AddEvent_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
