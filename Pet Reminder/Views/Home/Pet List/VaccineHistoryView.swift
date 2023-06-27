//
//  VaccineHistoryView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct VaccineHistoryView: View {

    var pet: Pet
    @Environment(\.dismiss) var dismiss
    @State private var vaccineName = ""
    @State private var vaccineDate = Date.now
    @State private var shouldAddVaccine = false
    @Environment(\.modelContext) private var modelContext

    func sortedVaccines(_ vaccines: [Vaccine]) -> [Vaccine] {
        vaccines.sorted(by: { $0.date ?? .now > $1.date ?? .now })
    }

    var body: some View {
        NavigationView {
            VStack {
                if let vaccines = pet.vaccines {
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
        let vaccine = Vaccine()
        vaccine.name = vaccineName
        vaccine.date = vaccineDate
        pet.vaccines?.append(vaccine)

        resetTemporaryData()
        togglePopup()
    }

    func resetTemporaryData() {
        vaccineName = ""
        vaccineDate = .now
    }

    func deleteVaccines(_at offsets: IndexSet) {
        if let vaccines = pet.vaccines {
            for offset in offsets {
                modelContext.delete(vaccines[offset])
            }
        }
    }
}

struct VaccineHistoryDemo: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            VaccineHistoryView(pet: PreviewSampleData.previewPet)
                .modelContainer(for: Pet.self)
        }
    }
}

// #Preview {
//    let titles = Strings.demoVaccines
//    let pet = Pet(birthday: .now,
//                  //choice: .both,
//                  createdAt: .now,
//                  eveningFed: false,
//                  eveningTime: .now,
//                  image: nil,
//                  morningFed: false,
//                  morningTime: .now,
//                  name: "")
//    
//    for _ in 0..<titles.count {
//        let components = DateComponents(
//            year: Int.random(
//                in: 2018...2023
//            ),
//            month: Int.random(
//                in: 0...12
//            ),
//            day: Int.random(
//                in: 0...30
//            ),
//            hour: Int.random(
//                in: 0...23
//            ),
//            minute: Int.random(
//                in: 0...59
//            ),
//            second: Int.random(
//                in: 0...59
//            )
//        )
//        let vaccine = Vaccine()
//        vaccine.name = titles.randomElement() ?? ""
//        vaccine.date = Calendar.current.date(from: components)
//        pet.vaccines?.append(vaccine)
//    }
//    
//    return VaccineHistoryView(pet: pet)
//        .modelContainer(for: Pet.self)
// }
