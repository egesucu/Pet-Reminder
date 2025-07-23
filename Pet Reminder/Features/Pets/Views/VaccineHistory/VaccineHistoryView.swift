//
//  VaccineHistoryView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import Shared
import SFSafeSymbols

struct VaccineHistoryView: View {

    @Binding var pet: Pet
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = VaccineHistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if let vaccines = pet.vaccines {
                    List {
                        ForEach(vaccines) { vaccine in
                            VStack {
                                HStack {
                                    Label {
                                        Text(.vaccineTitleLabel)
                                            .bold()
                                    } icon: {
                                        Image(systemSymbol: .syringeFill)
                                            .font(.headline)
                                            .symbolRenderingMode(.palette)
                                            .symbolEffect(.bounce, options: .repeat(3))
                                            .foregroundStyle(.blue, .white)
                                    }
                                    Spacer()
                                    Text(vaccine.name)
                                }

                                HStack {
                                    Label {
                                        Text(.vaccineDateLabel)
                                            .bold()
                                    } icon: {
                                        Image(systemSymbol: .hourglassBottomhalfFilled)
                                            .font(.headline)
                                            .symbolRenderingMode(.palette)
                                            .symbolEffect(.bounce, options: .repeat(3))
                                            .foregroundStyle(.blue, .white)
                                    }

                                    Spacer()
                                    Text((vaccine.date).formatted())
                                }
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteVaccines(pet: pet, at: indexSet)
                        }
                    }
                    .listStyle(.automatic)
                } else {
                    Text(.noVaccineTitle)
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.topBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemSymbol: SFSymbol.xmarkCircle)
                            .tint(.red)
                            .font(.title2)
                    }.disabled(viewModel.shouldAddVaccine)
                }
                ToolbarItem(placement: ToolbarItemPlacement.topBarTrailing) {
                    Button {
                        viewModel.shouldAddVaccine.toggle()
                    } label: {
                        Image(systemSymbol: SFSymbol.plusCircle)
                            .tint(.blue)
                            .font(.title2)
                    }
                    .disabled(viewModel.shouldAddVaccine)
                }
            }
            .navigationTitle(Text(.vaccineHistoryTitle))
            .navigationBarTitleTextColor(.blue)
            .popupView(
                isPresented: $viewModel.shouldAddVaccine,
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
    NavigationStack {
        VaccineHistoryView(pet: .constant(.preview))
            .modelContainer(DataController.previewContainer)
    }
}
