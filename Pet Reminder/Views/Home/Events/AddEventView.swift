//
//  AddEventView.swift
//  AddEventView
//
//  Created by Ege Sucu on 11.09.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct AddEventView: View {

    @StateObject var eventVM = EventManager()
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    let feedback = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Strings.addEventInfo)) {
                    TextField(Strings.addEventName, text: $eventVM.eventName)
                }
                Section(header: Text(Strings.addEventTime)) {
                    Toggle(Strings.allDayTitle, isOn: $eventVM.isAllDay)
                    eventDateView()
                }
            }
            .accentColor(tintColor)
            .navigationTitle(Text(Strings.addEventTitle))
            .toolbar(content: addEventToolbar)
        }
    }

    @ViewBuilder
    func eventDateView() -> some View {
        if eventVM.isAllDay {
            DatePicker(Strings.addEventDate, selection: $eventVM.allDayDate, displayedComponents: .date)
        } else {
            DatePicker(Strings.addEventStart, selection: $eventVM.eventStartDate)
                .onChange(of: eventVM.eventStartDate, perform: changeEventMinimumDate(_:))
            DatePicker(Strings.addEventEnd, selection: $eventVM.eventEndDate)
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
            Text(Strings.addEventSave)
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
