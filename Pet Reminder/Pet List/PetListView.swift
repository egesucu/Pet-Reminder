//
//  PetListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData
import OSLog

struct PetListView: View {

    var reference: PetListViewReference = .petList

    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.undoManager) var undoManager
    @State private var addPet = false
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen
    @Binding var tappedTwice: Bool

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    var pets: FetchedResults<Pet>
    @State private var showUndoButton = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    if pets.count > 0 {
                        ScrollViewReader { proxy in
                            petsView
                                .onChange(of: tappedTwice) { oldValue, newValue in
                                    if newValue != oldValue {
                                        if newValue {
                                            withAnimation {
                                                proxy.scrollTo(pets.first?.name, anchor: .top)
                                            }
                                            tappedTwice.toggle()
                                        } else {
                                            Logger
                                                .viewCycle
                                                .debug("Not scrolled, TapTwice Value: \(tappedTwice.description)")
                                        }
                                    }
                                }
                        }

                    } else {
                        switch reference {
                        case .petList:
                            EmptyPageView(onAddPet: {
                                addPet.toggle()
                            }, emptyPageReference: .petList)
                        case .settings:
                            EmptyPageView(emptyPageReference: .settings)
                        }
                    }
                }
                if showUndoButton {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGroupedBackground))
                            .padding(.horizontal, 10)
                        Button("Undo Last Change") {
                            withAnimation {
                                undoManager?.undo()
                                showUndoButton.toggle()
                            }
                        }
                    }
                    .frame(height: 40)
                }
            }
            .toolbar(content: addButtonToolbar)
            .onAppear(perform: {
                viewContext.undoManager = undoManager
            })
            .navigationTitle(petListTitle)
            .sheet(isPresented: $addPet, onDismiss: { }, content: {
                NewAddPetView()
            })
        }
    }

    private var petsView: some View {
        List {
            ForEach(pets, id: \.name) { pet in
                NavigationLink {
                    switch reference {
                    case .petList:
                        PetDetailView(pet: pet)
                            .id(pet.name)
                    case .settings:
                        PetChangeView(pet: pet)
                            .id(pet.name)
                    }
                } label: {
                    PetCell(pet: pet)
                        .padding()
                        .transition(.slide)
                }
            }.onDelete { indexSet in
                withAnimation {
                    deletePet(at: indexSet)
                }

            }
        }
    }

    private var petListTitle: Text {
        Text(reference == .settings ? "manage_pet_title" : "pet_name_title")
    }

    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if reference == .petList && pets.count > 0 {
                Button(action: {
                    self.addPet.toggle()
                }, label: {
                    Image(systemName: SFSymbols.add)
                        .accessibilityLabel(Text("add_animal_accessible_label"))
                        .foregroundColor(tintColor)
                        .font(.title)
                })
            }
        }
    }

    func deletePet(at indexSet: IndexSet) {
        for index in indexSet {
            let pet = pets[index]
            viewContext.delete(pet)
            PersistenceController.shared.save()
            showUndoButton.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        PetListView(tappedTwice: .constant(false))
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
    }
}

enum PetListViewReference {
    case petList, settings
}
