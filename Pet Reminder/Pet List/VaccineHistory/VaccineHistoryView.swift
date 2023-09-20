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

    @Binding var pet: Pet?
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = VaccineHistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if let pet {
                    if pet.vaccinesArray.isEmpty {
                        Text("no_vaccine_title")
                    } else {
                        List {
                            ForEach(pet.vaccinesArray) { vaccine in
                                HStack {
                                    Label {
                                        Text(vaccine.name)
                                            .bold()
                                    } icon: {
                                        Image(systemName: SFSymbols.vaccine)
                                    }
                                    Spacer()
                                    Text((vaccine.date).formatted())
                                }
                            }.onDelete { indexSet in
                                viewModel.deleteVaccines(pet: pet, at: indexSet)
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
            .popupView(
                isPresented: $viewModel.shouldAddVaccine.animation(),
                content: AddPopupView(
                    contentInput: $viewModel.vaccineName,
                    dateInput: $viewModel.vaccineDate,
                    onSave: {
                        viewModel.saveVaccine(
                            pet: pet
                        )
                    },
                    onCancel: viewModel.cancelVaccine
                )
            )
        }
    }
}

#Preview {
    return NavigationStack {
        VaccineHistoryView(pet: .constant(.init()))
            .modelContainer(for: Pet.self)

    }
}
