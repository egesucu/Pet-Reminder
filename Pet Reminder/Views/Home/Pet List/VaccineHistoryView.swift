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

    var pet: Pet
    @Environment(\.dismiss) var dismiss
    @State private var vaccineName = ""
    @State private var vaccineDate = Date.now
    @State private var shouldAddVaccine = false
    @Environment(\.managedObjectContext) private var modelContext

    func sortedVaccines(_ vaccines: [Vaccine]) -> [Vaccine] {
        vaccines.sorted(by: { $0.date ?? .now > $1.date ?? .now })
    }

    var body: some View {
        NavigationView {
            VStack {
                if let vaccines = pet.vaccines,
                   let vaccineArray = vaccines.allObjects as? [Vaccine] {
                    if vaccineArray.count == 0 {
                        Text("no_vaccine_title")
                    } else {
                        List {
                            ForEach(sortedVaccines(vaccineArray)) { vaccine in
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
                            }.onDelete(perform: deleteVaccines)
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
                    }.disabled(shouldAddVaccine)
                }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button(action: togglePopup) {
                        Image(systemName: SFSymbols.add)
                            .tint(.blue)
                    }.disabled(shouldAddVaccine)
                }
            }
            .navigationTitle(Text("vaccine_history_title"))
            .popupView(isPresented: $shouldAddVaccine.animation()) {
                AddPopupView(
                    contentInput: $vaccineName,
                    dateInput: $vaccineDate,
                    onSave: saveVaccine,
                    onCancel: cancelVaccine
                )
            }
        }

    }

    func cancelVaccine() {
        togglePopup()
        resetTemporaryData()
    }

    func togglePopup() {
        withAnimation {
            shouldAddVaccine.toggle()
        }
    }

    func saveVaccine() {
        let vaccine = Vaccine(context: modelContext)
        vaccine.name = vaccineName
        vaccine.date = vaccineDate
        pet.addToVaccines(vaccine)

        resetTemporaryData()
        togglePopup()
    }

    func resetTemporaryData() {
        vaccineName = ""
        vaccineDate = .now
    }

    func deleteVaccines(_at offsets: IndexSet) {
        if let vaccineSet = pet.vaccines,
           let vaccines = vaccineSet.allObjects as? [Vaccine] {
            for offset in offsets {
                modelContext.delete(vaccines[offset])
            }
        }
    }
}

#Preview {
    return NavigationView {
        VaccineHistoryView(pet: .init())
    }
}
