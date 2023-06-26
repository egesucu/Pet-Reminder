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
    var context: NSManagedObjectContext
    @Environment(\.dismiss) var dismiss
    @State private var vaccineName = ""
    @State private var vaccineDate = Date.now
    @State private var shouldAddVaccine = false

    var body: some View {
        NavigationView {
            VStack {
                if let vaccineSet = pet.vaccines,
                   let vaccines = vaccineSet.allObjects as? [Vaccine] {
                    if vaccines.count == 0 {
                        Text("no_vaccine_title")
                    } else {
                        List {
                            ForEach(vaccines.sorted(by: { $0.date ?? .now > $1.date ?? .now })) { vaccine in
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
        let vaccine = Vaccine(context: context)
        vaccine.name = vaccineName
        vaccine.date = vaccineDate
        pet.addToVaccines(vaccine)
        PersistenceController.shared.save()
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
                context.delete(vaccines[offset])
            }
        }
    }
}

struct VaccineHistoryView_Previews: PreviewProvider {

    static var previews: some View {
        let titles = Strings.demoVaccines
        let context = PersistenceController.preview.container.viewContext
        let pet = Pet(context: context)
        pet.name = Strings.viski
        for _ in 0..<titles.count {
            let components = DateComponents(
                year: Int.random(
                    in: 2018...2023
                ),
                month: Int.random(
                    in: 0...12
                ),
                day: Int.random(
                    in: 0...30
                ),
                hour: Int.random(
                    in: 0...23
                ),
                minute: Int.random(
                    in: 0...59
                ),
                second: Int.random(
                    in: 0...59
                )
            )
            let vaccine = Vaccine(context: context)
            vaccine.name = titles.randomElement() ?? ""
            vaccine.date = Calendar.current.date(from: components)
            pet.addToVaccines(vaccine)
        }
        return NavigationView {
            VaccineHistoryView(pet: pet, context: context)
        }
    }
}
