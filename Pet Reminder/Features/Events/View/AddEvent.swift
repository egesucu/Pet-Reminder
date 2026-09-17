//
//  AddEvent.swift
//  AddEvent
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import OSLog
import Shared

struct AddEvent: View {

    @Environment(EventManager.self) private var manager
    @Environment(\.dismiss) var dismiss

    @State private var eventName = String.empty
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

    @State private var saveError: String?
    @State private var showSaveError = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    header: Text(.addEventInfo)
                ) {
                    TextField(text: $eventName) {
                        Text(.addEventName)
                    }
                }
                Section(
                    header: Text(.addEventTime)
                ) {
                    Toggle(isOn: $allDay) {
                        Text(.allDayTitle)
                    }
                    eventDateView()
                }
            }
            .tint(.accent)
            .navigationTitle(Text(.addEventTitle))
            .toolbar(content: addEventToolbar)
            .disabled(isSaving)
            .alert(.saveFailed, isPresented: $showSaveError) { } message: {
                Text(saveError ?? String(localized: .unknownError))
            }
        }
    }

    @ContentBuilder
    func eventDateView() -> some View {
        if allDay {
            DatePicker(selection: $startDate, displayedComponents: .date) {
                Text(.addEventDate)
            }
        } else {
            DatePicker(selection: $startDate) {
                Text(.addEventStart)
            }
            .onChange(of: startDate, changeEventMinimumDate)
            DatePicker(selection: $endDate, in: startDate...) {
                Text(.addEventEnd)
            }
        }
    }

    @ContentBuilder
    func addEventToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            cancelButton()
        }
        ToolbarItem(placement: .topBarTrailing) {
            saveButton()
        }
    }

    private func changeEventMinimumDate() {
        endDate = startDate.addingTimeInterval(60*60)
    }

    private func saveButton() -> some View {
        Button(action: saveEvent) {
            Text(.addEventSave)
                .foregroundStyle(.accent)
                .bold()
        }
        .disabled(eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (!allDay && endDate < startDate))
    }

    private func cancelButton() -> some View {
        Button(action: dismiss.callAsFunction) {
            Text(.cancelTitle)
        }
        .foregroundStyle(Color.red)
        .bold()
    }

    private func saveEvent() {
        guard !isSaving else { return }
        isSaving = true
        Task {
            defer { isSaving = false }
            do {
                try await manager.saveEvent(
                    name: eventName,
                    start: startDate,
                    end: endDate,
                    allDay: allDay
                )
                dismiss()
            } catch {
                saveError = error.localizedDescription
                showSaveError = true
            }
        }
    }

}

#if DEBUG
#Preview {
    AddEvent()
        .environment(EventManager.demo)
}
#endif
