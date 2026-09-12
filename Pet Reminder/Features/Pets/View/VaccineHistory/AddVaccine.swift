//
//  AddVaccine.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2025.
//  Copyright © 2025 Ege Sucu. All rights reserved.
//

/// View for adding a new vaccine record to a pet,
/// including fields for vaccine name and date, and logic to persist the entry.

import SwiftUI
import SwiftData
import Shared
import OSLog

/// A SwiftUI view that provides a UI for entering and saving a new vaccine for a selected pet.
struct AddVaccine: View {

    /// The environment dismiss action to close the sheet after saving.
    @Environment(\.dismiss) var dismiss
    /// The pet to which the new vaccine will be added.
    let pet: Pet
    /// The name of the vaccine being entered by the user.
    @Binding var vaccineName: String
    /// The date selected for the new vaccine (defaults to now).
    @State private var vaccineDate = Date.now

    var isVaccineEmpty: Bool {
        vaccineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// The main UI with fields for vaccine name, date, and a button to save the record.
    var body: some View {
        NavigationStack {
            VStack(spacing: .spacing16) {
                TextField(.vaccineTitleLabel, text: $vaccineName)
                    .textFieldStyle(.outlined)
                    .bold()
                DatePicker(.vaccineDateLabel, selection: $vaccineDate)
                    .bold()
            }
            .navigationTitle(Text(.addVaccine))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .confirm, action: saveVaccine) {
                        Text(.save)
                    }
                    .tint(.accent)
                    .disabled(isVaccineEmpty)
                }
            }
        }

        .padding()
    }

    /// Creates and saves a new vaccine to the pet, persists the change, and resets the form.
    func saveVaccine() {
        let cleanedName = vaccineName.trimmingCharacters(in: .whitespacesAndNewlines)
        let vaccine = Vaccine(date: vaccineDate, name: cleanedName)
        pet.addVaccine(vaccine)
        do {
            try pet.modelContext?.save()
        } catch {
            Logger().error("Vaccine could not be saved: \(error)")
        }

        vaccineName = .empty
        vaccineDate = .now
        dismiss()
    }
}
#if DEBUG
/// Preview for AddVaccineView with an empty vaccine name.
#Preview("Add Vaccine", traits: .fixedLayout(width: 400, height: 200)) {
    @Previewable @State var vaccineName = String.empty
    @Previewable @State var showSheet = true

    Rectangle()
        .fill(Color.gray)
        .sheet(isPresented: $showSheet) {
            AddVaccine(pet: .preview, vaccineName: $vaccineName)
                .modelContainer(DataController.previewContainer)
                .presentationDetents([.fraction(.compactFraction)])
        }
}

/// Preview for AddVaccineView with a pre-filled vaccine name.
#Preview("Add Vaccine w Text", traits: .fixedLayout(width: 400, height: 200)) {
    @Previewable @State var vaccineName = "Pulvarin"
    @Previewable @State var showSheet = true

    Rectangle()
        .fill(Color.gray)
        .sheet(isPresented: $showSheet) {
            AddVaccine(pet: .preview, vaccineName: $vaccineName)
                .modelContainer(DataController.previewContainer)
                .presentationDetents([.fraction(.compactFraction)])
        }
}
#endif


struct OutlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 2)
            }
    }
}

extension TextFieldStyle where Self == OutlinedTextFieldStyle {

    internal static var outlined: OutlinedTextFieldStyle {
        OutlinedTextFieldStyle()
    }
}
