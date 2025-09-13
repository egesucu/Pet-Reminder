//
//  AddVaccineView.swift
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
import SFSafeSymbols
import OSLog

/// A SwiftUI view that provides a UI for entering and saving a new vaccine for a selected pet.
struct AddVaccineView: View {

    /// The environment dismiss action to close the sheet after saving.
    @Environment(\.dismiss) var dismiss
    /// The pet to which the new vaccine will be added.
    @Binding var pet: Pet
    /// The name of the vaccine being entered by the user.
    @Binding var vaccineName: String
    /// The date selected for the new vaccine (defaults to now).
    @State private var vaccineDate = Date.now

    /// Initializes the view with bindings to the selected pet and vaccine name.
    init(
        pet: Binding<Pet>,
        vaccineName: Binding<String>
    ) {
        self._pet = pet
        self._vaccineName = vaccineName
    }

    /// The main UI with fields for vaccine name, date, and a button to save the record.
    var body: some View {
        VStack(spacing: 15) {
            TextField(.vaccineTitleLabel, text: $vaccineName)
                .bold()
            DatePicker(.vaccineDateLabel, selection: $vaccineDate)
                .bold()
            Button(role: .confirm, action: saveVaccine) {
                Text("Save")
                    .font(.title)
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
            .disabled(vaccineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    /// Creates and saves a new vaccine to the pet, persists the change, and resets the form.
    func saveVaccine() {
        let vaccine = Vaccine(date: vaccineDate, name: vaccineName)
        pet.vaccines?.append(vaccine)
        do {
            try pet.modelContext?.save()
        } catch {
            Logger().error("Vaccine could not be saved: \(error)")
        }

        vaccineName = ""
        vaccineDate = .now
        dismiss()
    }
}
#if DEBUG
/// Preview for AddVaccineView with an empty vaccine name.
#Preview("Add Vaccine", traits: .fixedLayout(width: 400, height: 200)) {
    @Previewable @State var pet: Pet = .preview
    @Previewable @State var vaccineName = ""

    AddVaccineView(pet: $pet, vaccineName: $vaccineName)
        .modelContainer(DataController.previewContainer)
        .background(Color.red.opacity(0.2)) // Preview Heights
}

/// Preview for AddVaccineView with a pre-filled vaccine name.
#Preview("Add Vaccine w Text", traits: .fixedLayout(width: 400, height: 200)) {
    @Previewable @State var pet: Pet = .preview
    @Previewable @State var vaccineName = "Pulvarin"

    AddVaccineView(pet: $pet, vaccineName: $vaccineName)
        .modelContainer(DataController.previewContainer)
        .background(Color.red.opacity(0.2)) // Preview Heights
}
#endif
