//
//  VaccineHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

/// Displays and manages the vaccine history for a selected pet,
/// allowing users to add, view, and remove vaccine records.

import SwiftUI
import SwiftData
import Shared

/// A SwiftUI view that presents a list of vaccines associated with a pet,
/// supporting addition and deletion of vaccine records.
struct VaccineHistory: View {

    /// The pet whose vaccine history is displayed and modified.
    let pet: Pet

    /// Controls the presentation of the Add Vaccine sheet.
    @State private var shouldAddVaccine = false
    /// Stores the name of the vaccine to be added.
    @State private var vaccineName = String.empty

    /// Returns a formatted view representing a single vaccine entry.
    /// - Parameter vaccine: A Vaccine object to display.
    /// - Returns: A view showing the vaccine's name and date.
    @ContentBuilder
    func vaccineView(_ vaccine: Vaccine) -> some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            Label(vaccine.name, systemImage: "syringe.fill")
                .tint(.blue)
                .bold()
            Label(vaccine.date.formatted(), systemImage: "hourglass.bottomhalf.filled")
                .tint(.blue)
                .bold()
        }
    }

    /// The main content for the vaccine history,
    /// including a list of vaccines and controls for adding/removing entries.
    var body: some View {
        VStack {
            if let vaccines = pet.vaccines {
                List {
                    ForEach(vaccines, content: vaccineView)
                        .onDelete(perform: removeVaccine)
                }
                .listStyle(.automatic)
            } else {
                Text(.noVaccineTitle)
            }
        }
        .toolbar(content: vaccineToolbars)
        .navigationTitle(Text(.vaccineHistoryTitle))
        .sheet(isPresented: $shouldAddVaccine) {
            AddVaccine(pet: pet, vaccineName: $vaccineName)
                .presentationDetents([.fraction(.compactFraction)])
        }
    }

    /// Builds toolbar items for adding vaccines.
    @ContentBuilder func vaccineToolbars() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm, action: addVaccine) {
                Image(systemName: "plus")
                    .foregroundStyle(Color.background)
            }
            .tint(.blue)
            .disabled(shouldAddVaccine)
        }
    }

    /// Presents the Add Vaccine sheet when called.
    private func addVaccine() {
        shouldAddVaccine.toggle()
    }

    /// Deletes vaccines at the provided offsets from the pet's vaccine list.
    /// - Parameter offset: The set of indices representing vaccines to delete.
    private func removeVaccine(_ offset: IndexSet) {
        if let vaccines = pet.vaccines {
            for place in offset {
                pet.modelContext?.delete(vaccines[place])
            }
        }
    }
}

#if DEBUG
/// Preview for VaccineHistoryView using sample pet data.
#Preview("Vaccine List") {
    NavigationStack {
        VaccineHistory(pet: .preview)
            .modelContainer(DataController.previewContainer)
    }
}
#endif
