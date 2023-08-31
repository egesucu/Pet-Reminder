//
//  VaccineHistoryView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct VaccineHistoryView: View {

    var pet: Pet?
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var modelContext
    @State private var viewModel = VaccineHistoryViewModel()

    func sortedVaccines(_ vaccines: [Vaccine]) -> [Vaccine] {
        vaccines.sorted(by: { $0.date ?? .now > $1.date ?? .now })
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let pet,
                   let vaccineSet = pet.vaccines,
                   let vaccines = vaccineSet.allObjects as? [Vaccine] {
                    if vaccines.count == 0 {
                        Text("no_vaccine_title")
                    } else {
                        List {
                            ForEach(sortedVaccines(vaccines)) { vaccine in
                                HStack {
                                    Label {
                                        Text(vaccine.name ?? "")
                                            .bold()
                                    } icon: {
                                        Image(systemName: SFSymbols.vaccine)
                                    }
                                    Spacer()
                                    Text((vaccine.date ?? Date.now).formatted())
                                }
                            }.onDelete { indexSet in
                                viewModel.deleteVaccines(pet: pet, at: indexSet, modelContext: modelContext)
                            }
                        }
                        .listStyle(.automatic)
                    }

                } else {
                    Text("no_vaccine_title")
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: SFSymbols.close)
                            .tint(.blue)
                            .font(.title)
                    }.disabled(viewModel.shouldAddVaccine)
                }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button(action: viewModel.togglePopup) {
                        Image(systemName: SFSymbols.add)
                            .tint(.blue)
                            .font(.title)
                    }.disabled(viewModel.shouldAddVaccine)
                }
            }
            .navigationTitle(Text("vaccine_history_title"))
            .popupView(isPresented: $viewModel.shouldAddVaccine.animation()) {
                AddPopupView(
                    contentInput: $viewModel.vaccineName,
                    dateInput: $viewModel.vaccineDate,
                    onSave: { viewModel.saveVaccine(pet: pet) },
                    onCancel: viewModel.cancelVaccine
                )
            }
        }
    }
}

#Preview {
    let preview = PersistenceController.preview.container.viewContext
    return NavigationStack {
        VaccineHistoryView(pet: Pet(context: preview))
            .environment(\.managedObjectContext, preview)

    }
}
