//
//  AddEvent.swift
//  AddEvent
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI

struct AddEvent: View {

    @Environment(EventManager.self) private var manager
    @Environment(\.dismiss) var dismiss

    @State private var showDiscard = false
    @State private var creation = EventCreationState()

    var body: some View {
        @Bindable var creation = creation
        return NavigationStack {
            Form {
                Section(
                    header: Text(SharedStrings.addEventInfo)
                ) {
                    TextField(text: $creation.name) {
                        Text(SharedStrings.addEventName)
                    }
                }
                Section {
                    LabeledContent {
                        Text(manager.petCalendar?.title ?? "Pet Reminder")
                    } label: {
                        Text(SharedStrings.resource("Calendar"))
                    }
                    LabeledContent {
                        Text(SharedStrings.resource("10 minutes before"))
                    } label: {
                        Text(SharedStrings.resource("Reminder"))
                    }
                }
                Section(
                    header: Text(SharedStrings.addEventTime)
                ) {
                    Toggle(isOn: $creation.allDay) {
                        Text(SharedStrings.allDayTitle)
                    }
                    eventDateView()
                }
            }
            .onChange(of: creation.start) { old, new in
                creation.end = Self.adjustedEndDate(oldStart: old, newStart: new, end: creation.end)
            }
            .tint(.accent)
            .navigationTitle(Text(SharedStrings.addEventTitle))
            .toolbar(content: addEventToolbar)
            .disabled(creation.isSaving)
            .alert(SharedStrings.saveFailed, isPresented: $creation.showError) { } message: {
                Text(creation.errorMessage ?? String(localized: SharedStrings.unknownError))
            }
        }
        .interactiveDismissDisabled(creation.hasChanges || creation.isSaving)
        .confirmDiscardChanges(isPresented: $showDiscard, discard: dismiss.callAsFunction)
    }

    private func requestDismiss() {
        guard !creation.isSaving else { return }
        if creation.hasChanges { showDiscard = true } else { dismiss() }
    }

    @ContentBuilder
    func eventDateView() -> some View {
        @Bindable var creation = creation
        if creation.allDay {
            DatePicker(selection: $creation.start, displayedComponents: .date) {
                Text(SharedStrings.addEventDate)
            }
        } else {
            DatePicker(selection: $creation.start) {
                Text(SharedStrings.addEventStart)
            }
            DatePicker(selection: $creation.end, in: creation.start...) {
                Text(SharedStrings.addEventEnd)
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

    static func adjustedEndDate(oldStart: Date, newStart: Date, end: Date) -> Date {
        EventCreationState.adjustedEnd(oldStart: oldStart, newStart: newStart, end: end)
    }

    private func saveButton() -> some View {
        Button(action: saveEvent) {
            if creation.isSaving {
                ProgressView().accessibilityLabel(Text(SharedStrings.resource("Saving event")))
            } else {
                Text(SharedStrings.addEventSave).bold()
            }
        }
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(!creation.canSave)
    }

    private func cancelButton() -> some View {
        Button(action: requestDismiss) {
            Text(SharedStrings.cancelTitle)
        }
        .keyboardShortcut(.cancelAction)

    }

    private func saveEvent() {
        Task {
            let saved = await creation.save { name, start, end, allDay in
                try await manager.saveEvent(name: name, start: start, end: end, allDay: allDay)
            }
            if saved { dismiss() }
        }
    }

}

#if DEBUG
#Preview {
    AddEvent()
        .environment(EventManager.demo)
}
#endif
