//
//  VaccineHistoryView.swift
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
import SFSafeSymbols
import OSLog

/// A SwiftUI view that presents a list of vaccines associated with a pet,
/// supporting addition and deletion of vaccine records.
struct VaccineHistoryView: View {

    /// The environment-provided dismiss action for closing the view.
    @Environment(\.dismiss) var dismiss
    /// The environment-provided model context for data operations.
    @Environment(\.modelContext) private var modelContext

    /// The pet whose vaccine history is displayed and modified.
    @Binding var pet: Pet

    /// Controls the presentation of the Add Vaccine sheet.
    @State private var shouldAddVaccine = false
    /// Stores the name of the vaccine to be added.
    @State private var vaccineName = ""

    /// Returns a formatted view representing a single vaccine entry.
    /// - Parameter vaccine: A Vaccine object to display.
    /// - Returns: A view showing the vaccine's name and date.
    @ViewBuilder
    func vaccineView(_ vaccine: Vaccine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(vaccine.name, systemSymbol: .syringeFill)
                .tint(.blue)
                .bold()
            Label(vaccine.date.formatted(), systemSymbol: .hourglassBottomhalfFilled)
                .tint(.blue)
                .bold()
        }
    }

    /// The main content and navigation stack for the vaccine history,
    /// including a list of vaccines and controls for adding/removing entries.
    var body: some View {
        NavigationStack {
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
            .navigationBarTitleTextColor(.blue)
            .sheet(isPresented: $shouldAddVaccine) {
                AddVaccineView(pet: $pet, vaccineName: $vaccineName)
                    .presentationDetents([.fraction(0.3)])
            }
        }
    }

    /// Builds toolbar items for dismissing or adding vaccines.
    @ToolbarContentBuilder func vaccineToolbars() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(
                "",
                systemImage: SFSymbol.xmark.rawValue,
                role: .cancel,
                action: dismiss.callAsFunction
            )
            .disabled(shouldAddVaccine)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(
                "",
                systemImage: SFSymbol.plus.rawValue,
                role: .confirm,
                action: addVaccine
            )
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

/// Preview for VaccineHistoryView using sample pet data.
#Preview("Vaccine List") {
    @Previewable @State var pet: Pet = .preview

    NavigationStack {
        VaccineHistoryView(pet: $pet)
            .modelContainer(DataController.previewContainer)
    }
}
